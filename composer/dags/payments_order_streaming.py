from datetime import datetime, timedelta
import os

from airflow import DAG
from airflow.providers.google.cloud.operators.dataflow import DataflowCreatePythonJobOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.operators.bash import BashOperator

# Config via env vars or Airflow Variables
PROJECT = os.environ.get("GCP_PROJECT")
REGION = os.environ.get("GCP_REGION", "us-central1")
RAW_DATASET = os.environ.get("RAW_DATASET", "payments_raw")
TRUSTED_DATASET = os.environ.get("TRUSTED_DATASET", "payments_trusted")
TOPIC = os.environ.get("PUBSUB_TOPIC", "projects/{}/topics/payments.checkout.order.v1".format(PROJECT))

# OpenLineage (Airflow 2.7+ + OpenLineage provider) -> Configure connections/ENV in Composer image/env
# Great Expectations is called via BashOperator (checkpoint file exists in composer/ge/great_expectations)

default_args = {
    "owner": "data-platform",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="payments_order_streaming",
    default_args=default_args,
    description="Start Dataflow streaming, then validate DQ and MERGE raw->trusted",
    schedule_interval="*/30 * * * *",  # every 30 minutes run DQ+MERGE (streaming runs long)
    start_date=datetime(2025, 8, 1),
    catchup=False,
    max_active_runs=1,
    tags=["events","governance","payments"],
) as dag:

    start_dataflow = DataflowCreatePythonJobOperator(
        task_id="start_dataflow_streaming",
        py_file="/home/airflow/gcs/dags/dataflow/order_to_bq.py",
        job_name="df-orders-streaming-{{ ds_nodash }}",
        options={
            "project": PROJECT,
            "region": REGION,
            "runner": "DataflowRunner",
            "streaming": True,
            "input_topic": TOPIC,
            "output_table": f"{PROJECT}:{RAW_DATASET}.order_v1_raw",
            "temp_location": f"gs://{PROJECT}-tmp/dataflow",
            "num_workers": 2,
            "max_num_workers": 5,
            "autoscaling_algorithm": "THROUGHPUT_BASED",
        },
        location=REGION,
    )

    # Great Expectations checkpoint (validando trusted ou raw conforme estratégia)
    ge_validate = BashOperator(
        task_id="ge_validate_trusted",
        bash_command=(
            "cd /home/airflow/gcs/dags/ge/great_expectations && "
            "great_expectations checkpoint run orders_trusted"
        ),
        env={
            "GE_DATA_CONTEXT_ROOT_DIR": "/home/airflow/gcs/dags/ge/great_expectations"
        },
    )

    merge_job = BigQueryInsertJobOperator(
        task_id="merge_raw_to_trusted",
        configuration={
            "query": {
                "query": open("/home/airflow/gcs/dags/bq/sql/merge_orders_trusted.sql").read()
                .replace("${project}", PROJECT)
                .replace("${raw_dataset}", RAW_DATASET)
                .replace("${trusted_dataset}", TRUSTED_DATASET),
                "useLegacySql": False,
            }
        },
        location="US",
    )

    start_dataflow >> merge_job >> ge_validate
