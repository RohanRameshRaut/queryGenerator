#!/usr/bin/env bash

set -euo pipefail

if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
	echo "Error: Missing arguments."
	echo "Usage: ./build.sh <yaml_input_file> <sqlite_db_file> [schema_sql_file] [output_sql_file]"
	exit 1
fi

INPUT_FILE="$1"
DB_FILE="$2"
SCHEMA_FILE="${3:-schema.sql}" # Default
OUTPUT_FILE="${4:-output.sql}"

INTERPRETER="python3"
SCRIPT="main.py"

if [ ! -f "$INPUT_FILE" ]; then
    echo "    [Warning] Input file '$INPUT_FILE' not found. Skipping execution phase."
    exit 0
fi

"$INTERPRETER" "$SCRIPT" "$INPUT_FILE" > "$OUTPUT_FILE"

if [ -s "$OUTPUT_FILE" ]; then
    echo "    [Success] Execution finished. Output generated at '$OUTPUT_FILE'."
else
    echo "    [Error] Program executed but output file is empty." >&2
    exit 1
fi

if [ -f "$DB_FILE" ]; then
    rm "$DB_FILE"
    echo "    [Info] Removed existing database file '$DB_FILE'."
fi

sqlite3 "$DB_FILE" < "$SCHEMA_FILE"

sqlite3 "$DB_FILE" < "$OUTPUT_FILE"

echo "    [Success] Database saved to '$DB_FILE'."
