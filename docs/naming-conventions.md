# Naming Conventions

- **Projeto**: `org-{dominio}-{env}`
- **Tópico**: `{dominio}.{contexto}.{entidade}.{versao}` (ex.: `payments.checkout.order.v1`)
- **Subscription**: `{sistema-alvo}.{proposito}.{retencao}` (ex.: `bqloader.raw.7d`)
- **Dataset**: `{dominio}_{camada}` (ex.: `payments_raw`, `payments_trusted`)
- **Tabela**: `{entidade}_{versao}` (ex.: `order_v1`)
