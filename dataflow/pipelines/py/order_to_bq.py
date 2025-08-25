import argparse
import json
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, SetupOptions, StandardOptions, GoogleCloudOptions

class ParseEvent(beam.DoFn):
    def process(self, msg):
        # msg.data is bytes (Pub/Sub). On Dataflow Python template, input is decoded string.
        if isinstance(msg, (bytes, bytearray)):
            payload = msg.decode('utf-8')
        else:
            payload = msg
        try:
            data = json.loads(payload)
            # basic sanity validation
            required = ["event_id","event_type","event_version","source","occurred_at","order_id","customer_id","total_amount","currency"]
            if not all(k in data for k in required):
                return []
            # Keep items/pii_flags as JSON strings for raw
            data.setdefault("items", None if "items" not in data else json.dumps(data["items"]))
            data.setdefault("pii_flags", None if "pii_flags" not in data else json.dumps(data["pii_flags"]))
            yield data
        except Exception:
            # drop or route to DLQ (omitted: add Pub/Sub DLQ producer here)
            return []

def run(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", required=True)
    parser.add_argument("--region", required=True)
    parser.add_argument("--input_topic", required=True)
    parser.add_argument("--output_table", required=True)
    parser.add_argument("--temp_location", required=True)
    parser.add_argument("--staging_location", default=None)
    known_args, pipeline_args = parser.parse_known_args(argv)

    pipeline_options = PipelineOptions(pipeline_args)
    gco = pipeline_options.view_as(GoogleCloudOptions)
    gco.project = known_args.project
    gco.region = known_args.region
    gco.temp_location = known_args.temp_location
    pipeline_options.view_as(StandardOptions).streaming = True
    pipeline_options.view_as(SetupOptions).save_main_session = True

    schema = (
        "event_id:STRING,event_type:STRING,event_version:STRING,source:STRING,"
        "trace_id:STRING,correlation_id:STRING,occurred_at:TIMESTAMP,customer_id:STRING,"
        "order_id:STRING,total_amount:FLOAT,currency:STRING,payment_method:STRING,"
        "items:STRING,pii_flags:STRING"
    )

    with beam.Pipeline(options=pipeline_options) as p:
        _ = (
            p
            | "ReadPubSub" >> beam.io.ReadFromPubSub(topic=known_args.input_topic).with_output_types(bytes)
            | "ParseJSON" >> beam.ParDo(ParseEvent())
            | "WriteBQRaw" >> beam.io.WriteToBigQuery(
                known_args.output_table,
                schema=schema,
                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER,
                custom_gcs_temp_location=known_args.temp_location,
            )
        )

if __name__ == "__main__":
    run()
