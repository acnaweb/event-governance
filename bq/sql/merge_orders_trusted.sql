-- Dedupe por event_id mantendo o último occurred_at (ou outra lógica de negócio)
MERGE `${project}.${trusted_dataset}.order_v1` T
USING (
  SELECT AS VALUE
    ARRAY_AGG(r ORDER BY r.occurred_at DESC LIMIT 1)[OFFSET(0)]
  FROM `${project}.${raw_dataset}.order_v1_raw` r
  GROUP BY r.event_id
) S
ON T.event_id = S.event_id
WHEN MATCHED AND T.occurred_at < S.occurred_at THEN
  UPDATE SET
    event_type = S.event_type,
    event_version = S.event_version,
    source = S.source,
    trace_id = S.trace_id,
    correlation_id = S.correlation_id,
    occurred_at = S.occurred_at,
    customer_id = S.customer_id,
    order_id = S.order_id,
    total_amount = S.total_amount,
    currency = S.currency,
    payment_method = S.payment_method,
    items = S.items,
    pii_flags = S.pii_flags
WHEN NOT MATCHED THEN
  INSERT ROW
