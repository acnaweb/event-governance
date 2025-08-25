variable "dataset_id" {}
variable "table_id" {}
variable "schema_json" {}
variable "time_partitioning_field" { default = "occurred_at" }
variable "clustering_fields" { type = list(string), default = ["source","order_id"] }
variable "labels" { type = map(string), default = {} }

resource "google_bigquery_table" "this" {
  dataset_id = var.dataset_id
  table_id   = var.table_id

  schema = var.schema_json

  time_partitioning {
    type  = "DAY"
    field = var.time_partitioning_field
  }

  clustering = var.clustering_fields

  labels = var.labels
}

output "table_id" { value = google_bigquery_table.this.table_id }
