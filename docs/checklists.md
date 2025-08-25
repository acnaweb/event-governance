# Checklist de PR (Eventos e Ingestão)

## Contratos
- [ ] Schema (Avro/Proto) versionado e aprovado (compatibilidade verificada em CI).
- [ ] Envelope com `event_id`, `event_version`, `event_type`, `source`, `occurred_at` (UTC).
- [ ] Classificação de campos e **Policy Tags** mapeadas (PII/PCI).

## Pub/Sub
- [ ] Tópico nomeado conforme padrão `{dominio}.{contexto}.{entidade}.{versao}`.
- [ ] **Schema enforced** habilitado no tópico.
- [ ] DLQ definida nas subscriptions.

## BigQuery
- [ ] Dataset correto por domínio/camada (`*_raw`, `*_trusted`), com **labels de custo**.
- [ ] Tabelas **particionadas** por `occurred_at` e **clusterizadas** por chaves de consulta.
- [ ] **CMEK**/RLS/CLS quando aplicável.
- [ ] MERGE de dedupe definido e testado.

## DQ e Observabilidade
- [ ] Expectation Suite (GE) criada/atualizada.
- [ ] Dashboards de lag/taxa erro/volume e **alertas** configurados.
- [ ] **SLOs** definidos (freshness/latência/qualidade).

## Segurança e Acesso
- [ ] Acesso por grupos IAM (menor privilégio).
- [ ] Views autorizadas/masking para consumidores.

## Automação
- [ ] Terraform aplicado/testado (fmt/validate, conftest OK).
- [ ] DAG do Composer versionado e parametrizado.
