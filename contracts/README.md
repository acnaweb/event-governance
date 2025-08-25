# Data Contracts

- **Avro**: `contracts/payments/order/v1.avsc`
- **Protobuf**: `contracts/payments/order/v1.proto`
- **Exemplo de mensagem**: `contracts/examples/order_v1.json`

## Regras
- Envelope obrigatório: `event_id`, `event_type`, `event_version`, `source`, `occurred_at` (UTC RFC3339), `pii_flags`.
- Mudanças **breaking** requerem nova versão (`v2`) e coexistência.
- Campos novos devem ser **nullable/opcionais** (quando aplicável).
- CI valida compatibilidade e presença dos campos obrigatórios.
