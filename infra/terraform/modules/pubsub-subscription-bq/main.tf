variable "name" {}
variable "topic" {}
variable "bq_table" {}
variable "use_table_schema" { default = false }
variable "labels" { type = map(string), default = {} }

resource "google_pubsub_subscription" "this" {
  name  = var.name
  topic = var.topic

  bigquery_config {
    table            = var.bq_table
    write_metadata   = true
    use_table_schema = var.use_table_schema
  }

  ack_deadline_seconds = 20

  dead_letter_policy {
    dead_letter_topic = "${var.topic}.dlq"
    max_delivery_attempts = 10
  }

  labels = var.labels
}

output "subscription" { value = google_pubsub_subscription.this.name }
