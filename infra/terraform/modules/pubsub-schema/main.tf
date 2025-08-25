variable "name" {}
variable "type" { default = "AVRO" }
variable "definition" {}

resource "google_pubsub_schema" "this" {
  name       = var.name
  type       = var.type
  definition = var.definition
}

output "schema_id" { value = google_pubsub_schema.this.id }
