# Cricket Match Data Pipeline (YAML to PostgreSQL)

An automated pipeline that parses raw cricket match data from a YAML file, transforms it into normalized SQL insertions, and populates a PostgreSQL database using Python and Shell scripting.

---

## Project Structure

* **`cricket.yaml`**: Input file containing raw match data
* **`schema.sql`**: DDL file containing relational database definitions and constraints.
* **`main.py`**: Python parser that extracts YAML data and writes SQL `INSERT` statements to `output.sql`.
* **`build.sh`**: Shell script that automates starting PostgreSQL, recreating `cricket_db`, running `schema.sql`, and executing `output.sql`.
* **`output.sql`**: Auto-generated SQL insert queries produced by `main.py`.

---

## Database Schema

 layout contains **6 core tables**:

1. **`Match_Type`**: Tracks game formats (e.g., ODI, T20).
2. **`Team`**: Unique team records.
3. **`Player`**: Player records linked to their respective `teamID`.
4. **`Match`**: Contains match metadata, toss result, venue, date, and winner.
5. **`Inning`**: Summarizes team totals for 1st and 2nd innings.
6. **`Match_Record`**: Detailed delivery log (overs, runs, extras, striker, non-striker, and bowler IDs).

---

## Prerequisites

Ensure the following are installed and configured on your Linux system:
* **Python 3**
* **PostgreSQL** service (`postgresql`)

---

## How to Run

1. Make sure your input file is named `cricket.yaml` and placed in the project root folder.
2. Grant execution permissions to the build script:
   ```bash
   chmod +x build.sh
   ```
3. Run the complete pipeline script:
   ```bash
   ./build.sh
   ```

*(Note: The build script will prompt for your system password to start the PostgreSQL service if it is not running).*

---

## Inspecting the Database

After a successful build, you can inspect the database directly using `psql`.

### 1. Connect to the Database
```bash
sudo -u postgres psql -d cricket_db
```

### 2. Useful Inspection Commands

* **List all tables:**
  ```sql
  \dt
  ```

* **Inspect table structure (columns & data types):**
  ```sql
  \d Player
  \d Match_Record
  ```

* **Query table rows:**
  ```sql
  -- View all teams
  SELECT * FROM Team;

  -- View top 10 players
  SELECT * FROM Player LIMIT 10;

  -- View match result and winner details
  SELECT matchID, date, venue, matchResult FROM Match;

  -- View first 10 deliveries of an inning
  SELECT matchRecordID, over, delivery, strikerRuns, total 
  FROM Match_Record 
  LIMIT 10;
  ```

* **Exit `psql`:**
  ```sql
  \q
  ```
