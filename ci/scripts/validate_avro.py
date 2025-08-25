import json, sys
from pathlib import Path

REQUIRED_FIELDS = {"event_id","event_type","event_version","source","occurred_at"}

def main():
    path = Path("contracts/payments/order/v1.avsc")
    schema = json.loads(path.read_text(encoding="utf-8"))
    fields = {f["name"] for f in schema["fields"]}
    missing = REQUIRED_FIELDS - fields
    if missing:
        print(f"[ERROR] Missing required fields in Avro schema: {sorted(missing)}")
        sys.exit(1)
    print("[OK] Avro schema contains required fields.")

if __name__ == "__main__":
    main()
