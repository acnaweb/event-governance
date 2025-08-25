variable "dataset_id" {}
variable "location" { default = "US" }
variable "labels" { type = map(string), default = {} }
variable "default_table_expiration_ms" { default = null }

resource "google_bigquery_dataset" "this" {
  dataset_id                  = var.dataset_id
  location                    = var.location
  default_table_expiration_ms = var.default_table_expiration_ms
  labels                      = var.labels
}

output "dataset_id" { value = google_bigquery_dataset.this.dataset_id }
