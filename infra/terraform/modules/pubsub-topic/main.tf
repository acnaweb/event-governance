variable "name" {}
variable "schema" { default = null }
variable "labels" { type = map(string), default = {} }
variable "kms_key_name" { default = null }

resource "google_pubsub_topic" "this" {
  name = var.name

  dynamic "schema_settings" {
    for_each = var.schema == null ? [] : [1]
    content {
      schema   = var.schema
      encoding = "JSON"
    }
  }

  kms_key_name = var.kms_key_name

  labels = var.labels
}

output "topic" { value = google_pubsub_topic.this.name }
