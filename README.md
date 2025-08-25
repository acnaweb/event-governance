# Event Governance GCP Blueprint

**Objetivo**: Prover um guia operacional e um _starter kit_ para governança de eventos no GCP, cobrindo:
- Templates **Terraform** (Pub/Sub, Schemas, BigQuery, Policy Tags, IAM, Composer)
- **Data Contracts** (Avro e Protobuf) com exemplos e validação
- **Blueprint** de **Composer + Dataflow** com DQ (Great Expectations) e **lineage** (OpenLineage)
- **Checklist de PR** e **Policy-as-Code** (Conftest/OPA)

> Estrutura do repositório:
```
contracts/                  # Avro/Proto + exemplos e validações
infra/terraform/            # Módulos e ambientes (dev como exemplo)
composer/                   # DAG de orquestração + Great Expectations
dataflow/                   # Pipeline Apache Beam (Python) - streaming Pub/Sub → BigQuery (raw)
policy/conftest/            # Regras OPA para validações em CI
ci/github/workflows/        # GitHub Actions (validações)
bq/sql/                     # SQLs úteis (MERGE dedupe, views)
docs/                       # Checklists, naming, SLOs
Makefile                    # Atalhos
```

## Fluxo de referência
1. **Produtor** publica no tópico `payments.checkout.order.v1` validado por **Pub/Sub Schema** (Avro/Proto).
2. **Dataflow (streaming)** consome o tópico e grava em BigQuery **raw** (particionado/clusterizado, sem dedupe).
3. **Airflow (Composer)** agenda **MERGE** para **trusted** (dedupe por `event_id` + `occurred_at`), roda **Great Expectations** e registra **lineage** (OpenLineage).
4. **Consumers** acessam tabelas **trusted** e **views autorizadas** com _masking_ por **Policy Tags**.

## Pré-requisitos
- GCP Project com APIs: Pub/Sub, BigQuery, Dataflow, Composer, Data Catalog.
- Terraform >= 1.5, provedor `hashicorp/google` recente.
- Python 3.10+ para Dataflow/GE.
- (Opcional) GitHub Actions para CI.

## Como usar (alta nível)
1. Ajuste `infra/terraform/envs/dev/variables.auto.tfvars` (projeto, região, nomes).
2. `make tf-init && make tf-apply` para criar tópicos, schemas, datasets, tabelas, policy tags.
3. Publique mensagens exemplo em `contracts/examples/`.
4. Publique pipeline de Dataflow (como Flex Template) e configure o DAG no Composer.
5. Rode o **MERGE** e a **validação GE** (via DAG).

> Consulte cada subpasta para detalhes específicos.
