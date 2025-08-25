package main

# Regras simples de exemplo para recursos Terraform exportados como HCL (heurística via arquivo)
deny[msg] {
  input.filename =~ "bigquery_table"
  not input.filecontent =~ "time_partitioning"
  msg := "BigQuery table sem time_partitioning"
}

deny[msg] {
  input.filename =~ "bigquery_table"
  not input.filecontent =~ "clustering"
  msg := "BigQuery table sem clustering"
}

deny[msg] {
  input.filename =~ "pubsub_topic"
  not input.filecontent =~ "labels"
  msg := "Pub/Sub topic sem labels de custo"
}

deny[msg] {
  input.filename =~ "pubsub_subscription"
  not input.filecontent =~ "dead_letter_policy"
  msg := "Subscription sem DLQ configurada"
}

deny[msg] {
  input.filename =~ "dataset"
  not input.filecontent =~ "labels"
  msg := "Dataset sem labels de custeio"
}
