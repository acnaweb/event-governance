variable "project_id" {}
variable "region" { default = "us-central1" }
variable "location" { default = "US" }

locals {
  labels = {
    owner    = "data-platform"
    domain   = "payments"
    env      = "dev"
    resource = "events"
  }
}

module "dataset_raw" {
  source   = "../../modules/bigquery-dataset"
  dataset_id = "payments_raw"
  location = var.location
  labels   = local.labels
}

module "dataset_trusted" {
  source   = "../../modules/bigquery-dataset"
  dataset_id = "payments_trusted"
  location = var.location
  labels   = local.labels
}

# Policy tags taxonomy
module "taxonomy" {
  source = "../../modules/policy-tags"
  taxonomy_display_name = "sensitivity"
}

# Tables (raw/trusted)
data "local_file" "avro_schema" {
  filename = "${path.module}/../../../contracts/payments/order/v1.avsc"
}

# Mapeie policy tags em schema JSON (exemplo simples)
locals {
  schema_raw = jsonencode({
    fields = [
      {"name":"event_id","type":"STRING","mode":"REQUIRED"},
      {"name":"event_type","type":"STRING","mode":"REQUIRED"},
      {"name":"event_version","type":"STRING","mode":"REQUIRED"},
      {"name":"source","type":"STRING","mode":"REQUIRED"},
      {"name":"trace_id","type":"STRING","mode":"NULLABLE"},
      {"name":"correlation_id","type":"STRING","mode":"NULLABLE"},
      {"name":"occurred_at","type":"TIMESTAMP","mode":"REQUIRED"},
      {"name":"customer_id","type":"STRING","mode":"REQUIRED","policyTags":{"names":[module.taxonomy.policy_tags.restricted]}},
      {"name":"order_id","type":"STRING","mode":"REQUIRED"},
      {"name":"total_amount","type":"FLOAT","mode":"REQUIRED"},
      {"name":"currency","type":"STRING","mode":"REQUIRED"},
      {"name":"payment_method","type":"STRING","mode":"NULLABLE"},
      {"name":"items","type":"STRING","mode":"NULLABLE","description":"Itens em JSON bruto"},
      {"name":"pii_flags","type":"STRING","mode":"NULLABLE","description":"Mapa serializado"}
    ]
  })

  schema_trusted = local.schema_raw
}

module "table_raw" {
  source                  = "../../modules/bigquery-table"
  dataset_id              = module.dataset_raw.dataset_id
  table_id                = "order_v1_raw"
  schema_json             = local.schema_raw
  time_partitioning_field = "occurred_at"
  clustering_fields       = ["source","order_id"]
  labels                  = local.labels
}

module "table_trusted" {
  source                  = "../../modules/bigquery-table"
  dataset_id              = module.dataset_trusted.dataset_id
  table_id                = "order_v1"
  schema_json             = local.schema_trusted
  time_partitioning_field = "occurred_at"
  clustering_fields       = ["source","order_id"]
  labels                  = local.labels
}

# Pub/Sub schema (Avro)
module "pubsub_schema" {
  source     = "../../modules/pubsub-schema"
  name       = "payments.checkout.order.v1"
  type       = "AVRO"
  definition = file("${path.module}/../../../contracts/payments/order/v1.avsc")
}

# Tópico com schema enforced
module "topic" {
  source = "../../modules/pubsub-topic"
  name   = "payments.checkout.order.v1"
  schema = module.pubsub_schema.schema_id
  labels = local.labels
}

# Subscription BigQuery (opcional: raw landing por BigQuery subscription)
module "subscription_bq_raw" {
  source     = "../../modules/pubsub-subscription-bq"
  name       = "bqloader.raw.7d"
  topic      = module.topic.topic
  bq_table   = "${var.project_id}:${module.dataset_raw.dataset_id}.${module.table_raw.table_id}"
  labels     = local.labels
}
