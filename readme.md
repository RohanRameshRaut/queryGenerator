# Cricket Match Data Pipeline (YAML to SQLite)

An automated pipeline that parses raw cricket match data from a YAML file, transforms it into normalized SQL insertions, and populates an embedded SQLite database using Python and Shell scripting.

---

## Project Structure

* **`<input_yaml_file>`**: Input file containing raw match data.
* **`<schema_sql_file>/schema.sql`**: DDL file containing relational database definitions, tables, and constraints.
* **`main.py`**: Python parser that extracts YAML data and writes SQL `INSERT` statements to `output.sql`.
* **`build.sh`**: Shell script that automates running `main.py`, initializing the SQLite database file, applying `schema.sql`, and executing `output.sql`.
* **`<output_sql_file>/output.sql`**: Auto-generated SQL insert queries produced by `main.py`.

---

## Database Schema

The relational layout contains **6 core tables**:

1. **`Match_Type`**: Tracks game formats (e.g., ODI, T20).
2. **`Team`**: Unique team records.
3. **`Player`**: Player records linked to their respective `teamID`.
4. **`Match`**: Contains match metadata, toss result, venue, date, and winner.
5. **`Inning`**: Summarizes team totals for 1st and 2nd innings.
6. **`Match_Record`**: Detailed delivery log (overs, runs, extras, striker, non-striker, and bowler IDs).

---

## Prerequisites

Ensure the following are installed on your Linux system:
* **Python 3**
* **SQLite3** (`sqlite3` command-line utility)

---

## How to Run

The `build.sh` script accepts filenames via command-line arguments.

1. Grant execution permissions to the build script:
   ```bash
   chmod +x build.sh
   ./build.sh <input_yaml_file> <sqlite_db_file> [schema.sql] [output_sql_file]
