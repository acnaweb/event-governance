variable "taxonomy_display_name" {}
variable "activated_policy_types" { type = list(string), default = ["FINE_GRAINED_ACCESS_CONTROL"] }
variable "policy_tags" {
  type = map(object({ description = string }))
  default = {
    public       = { description = "Dados públicos" }
    internal     = { description = "Uso interno" }
    confidential = { description = "Dados confidenciais" }
    restricted   = { description = "Dados restritos (PII/PCI)" }
  }
}

resource "google_data_catalog_taxonomy" "taxonomy" {
  display_name           = var.taxonomy_display_name
  activated_policy_types = var.activated_policy_types
}

resource "google_data_catalog_policy_tag" "tags" {
  for_each     = var.policy_tags
  taxonomy     = google_data_catalog_taxonomy.taxonomy.name
  display_name = each.key
  description  = each.value.description
}

output "policy_tags" {
  value = { for k, v in google_data_catalog_policy_tag.tags : k => v.name }
}
