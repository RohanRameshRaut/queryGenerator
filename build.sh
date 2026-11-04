#!/usr/bin/env bash

set -euo pipefail

INPUT_FILE="cricket.yaml"
OUTPUT_FILE="output.sql"
SCHEMA_FILE="schema.sql"
DB_NAME="cricket_db"
DB_USER="postgres"

INTERPRETER="python3"
SCRIPT="main.py"

if [ ! -f "$INPUT_FILE" ]; then
    echo "    [Warning] Input file '$INPUT_FILE' not found. Skipping execution phase."
    exit 0
fi

"$INTERPRETER" "$SCRIPT" < "$INPUT_FILE" > "$OUTPUT_FILE" 2> "error.log"

if [ -s "$OUTPUT_FILE" ]; then
    echo "    [Success] Execution finished. Output generated at '$OUTPUT_FILE'."[cite: 5]
else
    echo "    [Error] Program executed but output file is empty." >&2
    exit 1
fi

sudo systemctl start postgresql

dropdb -U "$DB_USER" --if-exists "$DB_NAME"

createdb -U "$DB_USER" "$DB_NAME"

psql -U "$DB_USER" -d "$DB_NAME" -f "$SCHEMA_FILE"

psql -U "$DB_USER" -d "$DB_NAME" -f "$OUTPUT_FILE"
