# SLOs sugeridos (exemplo)

- **Freshness (trusted)**: P95 <= 30 min entre `occurred_at` e disponibilidade em `*_trusted`.
- **Latência (streaming)**: P95 <= 2 min do Pub/Sub até `*_raw`.
- **Qualidade**: 99.9% dos registros com `event_id` não-nulo e único no horizonte de 7 dias.
- **Confiabilidade**: Taxa de erro de validação < 0.1%/hora, com alerta > 0.5%.
