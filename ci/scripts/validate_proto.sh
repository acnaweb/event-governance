#!/usr/bin/env bash
set -euo pipefail
FILE="contracts/payments/order/v1.proto"
required=( "event_id" "event_type" "event_version" "source" "occurred_at" )
for f in "${required[@]}"; do
  if ! grep -q "$f" "$FILE"; then
    echo "[ERROR] Campo obrigatório não encontrado no proto: $f"
    exit 1
  fi
done
echo "[OK] Proto contém campos obrigatórios."
