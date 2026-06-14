# Data Engineer Interview Prep — Practice Live
## Python · SQL · PySpark | Setup Guide

> **Start here.** This guide sets up everything you need before opening any day notebook.  
> Complete all sections in order: Python → PostgreSQL → pgAdmin → PySpark.

---

## Directory Structure

```
practice-live/
├── README.md                           ← you are here
├── requirements.txt                    ← all Python packages pinned
│
├── python/
│   ├── 00_prerequisites.ipynb          ← run before any Python day notebook
│   └── day01_loops_enumerate_zip/
│       ├── notes.md
│       └── notebook.ipynb
│
├── sql/
│   ├── 00_prerequisites.ipynb          ← run before any SQL day notebook
│   └── day01_filters_where_having/
│       ├── notes.md
│       └── notebook.ipynb
│
└── pyspark/
    ├── 00_prerequisites.ipynb          ← run before any PySpark day notebook
    └── day01_dataframe_filtering/
        ├── notes.md
        └── notebook.ipynb
```

---

## SECTION 1 — Python & Virtual Environment Setup

Do this first. Everything else (PostgreSQL, PySpark) runs inside this environment.

### Prerequisites

- Python 3.10 or 3.11 recommended (3.8+ minimum)
- Verify: `python --version` or `python3 --version`

---

### Windows

```powershell
# 1. Navigate to the project root
cd C:\Users\hariom\Downloads\python_sql_pyspark

# 2. Create a virtual environment named 'myenv'
python -m venv myenv

# 3. Activate it
myenv\Scripts\activate

# You will see (myenv) in your prompt when active

# 4. Upgrade pip
python -m pip install --upgrade pip

# 5. Install all requirements
pip install -r practice-live\requirements.txt

# 6. Register the environment as a Jupyter kernel
python -m ipykernel install --user --name myenv --display-name "Python (myenv)"

# 7. Launch JupyterLab
jupyter lab
```

**To deactivate when done:**
```powershell
deactivate
```

**To reactivate next time:**
```powershell
cd C:\Users\hariom\Downloads\python_sql_pyspark
myenv\Scripts\activate
jupyter lab
```

---

### macOS

```bash
# 1. Navigate to the project root
cd ~/Downloads/python_sql_pyspark

# 2. Create a virtual environment
python3 -m venv myenv

# 3. Activate it
source myenv/bin/activate

# You will see (myenv) in your prompt when active

# 4. Upgrade pip
pip install --upgrade pip

# 5. Install all requirements
pip install -r practice-live/requirements.txt

# 6. Register the environment as a Jupyter kernel
python -m ipykernel install --user --name myenv --display-name "Python (myenv)"

# 7. Launch JupyterLab
jupyter lab
```

**To deactivate:**
```bash
deactivate
```

---

### Ubuntu / Debian

```bash
# 1. Install Python venv support if missing
sudo apt update
sudo apt install -y python3-venv python3-pip

# 2. Navigate to project root
cd ~/Downloads/python_sql_pyspark    # adjust path as needed

# 3. Create a virtual environment
python3 -m venv myenv

# 4. Activate it
source myenv/bin/activate

# 5. Upgrade pip
pip install --upgrade pip

# 6. Install all requirements
pip install -r practice-live/requirements.txt

# 7. Register as Jupyter kernel
python -m ipykernel install --user --name myenv --display-name "Python (myenv)"

# 8. Launch JupyterLab
jupyter lab
```

---

### Verifying the Installation

After `pip install -r requirements.txt` completes, run this to confirm:

```bash
python -c "import pyspark, psycopg2, sqlalchemy, jupyter; print('All core packages OK')"
```

Expected output: `All core packages OK`

---

### Selecting the Kernel in JupyterLab

When you open any notebook:
1. Top-right corner → click the kernel name
2. Select **Python (myenv)** from the dropdown
3. If you don't see it — re-run the `ipykernel install` command above

---

## SECTION 2 — PostgreSQL Setup

Required for all SQL day notebooks. All queries run against a live PostgreSQL database.

---

### 2.1 Windows — Install PostgreSQL

**Step 1 — Download the installer**

Go to: https://www.postgresql.org/download/windows/  
Click **"Download the installer"** (EnterpriseDB) → select the latest **16.x** or **15.x** → Windows x86-64.

**Step 2 — Run the installer**

| Prompt | What to do |
|--------|-----------|
| Installation directory | Leave default: `C:\Program Files\PostgreSQL\16` |
| Components | Keep all checked (Server, pgAdmin, Command Line Tools) |
| Data directory | Leave default |
| **Password** | Set a password you will remember — e.g. `postgres` |
| Port | Leave `5432` |
| Locale | Leave default |
| Stack Builder | **Uncheck** — not needed |

**Step 3 — Add PostgreSQL bin to PATH**

Open: Start → search **"Edit the system environment variables"** → Environment Variables

Under **System variables**, click `Path` → Edit → New → add:
```
C:\Program Files\PostgreSQL\16\bin
```
*(Replace `16` with your installed version.)*

Click OK on all dialogs. **Open a new terminal** (old ones won't see the updated PATH).

**Step 4 — Verify**

```powershell
psql --version
psql -U postgres -c "SELECT version();"
# Enter your password when prompted
```

**Step 5 — Start / Stop the service**

PostgreSQL is installed as a Windows Service and starts automatically at boot.

```powershell
# Start
net start postgresql-x64-16

# Stop
net stop postgresql-x64-16

# Check status
sc query postgresql-x64-16
```

---

### 2.2 macOS — Install PostgreSQL

**Option A — Homebrew (recommended)**

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install PostgreSQL 16
brew install postgresql@16

# Add to PATH — add this line to ~/.zshrc (or ~/.bash_profile)
echo 'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Start the service
brew services start postgresql@16

# Verify
psql --version
psql postgres -c "SELECT version();"
```

**Create the postgres superuser with password** (Homebrew doesn't create it by default):

```bash
# Open psql as your macOS user
psql postgres

# Inside psql, run:
CREATE USER postgres WITH SUPERUSER PASSWORD 'postgres';
\q
```

**Option B — Postgres.app (GUI, no terminal needed)**

1. Download from: https://postgresapp.com
2. Drag to `/Applications` and open
3. Click **Initialize** in the app window
4. Click the elephant icon in the menu bar to start/stop
5. Add CLI tools: follow https://postgresapp.com/documentation/cli-tools.html

Default user with Postgres.app = your macOS username, no password.  
Update `USERNAME` in each day notebook's connection cell to match.

---

### 2.3 Ubuntu / Debian — Install PostgreSQL

```bash
# 1. Add the official PostgreSQL apt repository (gets latest version)
sudo apt install -y curl ca-certificates
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail \
    https://www.postgresql.org/media/keys/ACCC4CF8.asc
sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] \
    https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list'
sudo apt update

# 2. Install PostgreSQL 16
sudo apt install -y postgresql-16

# 3. Start and enable the service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# 4. Verify
sudo systemctl status postgresql
psql --version
```

**Set a password for the postgres user:**

```bash
# Switch to postgres OS user and open psql
sudo -u postgres psql

# Inside psql:
ALTER USER postgres WITH PASSWORD 'postgres';
\q
```

**Allow password authentication (md5) — edit pg_hba.conf:**

```bash
# Find the file location
sudo -u postgres psql -c "SHOW hba_file;"
# Typical output: /etc/postgresql/16/main/pg_hba.conf

# Open it
sudo nano /etc/postgresql/16/main/pg_hba.conf
```

Find this line:
```
local   all   postgres   peer
```
Change `peer` to `md5`:
```
local   all   postgres   md5
```

Also find this line (for TCP connections from localhost):
```
host    all   all   127.0.0.1/32   scram-sha-256
```
If it says `ident`, change to `md5` or `scram-sha-256`.

Reload to apply:
```bash
sudo systemctl reload postgresql

# Test with password
psql -U postgres -W
# Enter: postgres
```

---

### 2.4 Default Connection Settings

These are the values used in every SQL day notebook. Only `PASSWORD` may differ.

| Setting | Value | Notes |
|---------|-------|-------|
| `USERNAME` | `postgres` | Default superuser |
| `PASSWORD` | `postgres` | Whatever you set during install |
| `HOST` | `localhost` | Change only for remote servers |
| `PORT` | `5432` | Default — change only if you chose a different port |
| `DBNAME` | `postgres` | Always exists on any PostgreSQL install |

**macOS Homebrew users:** If you didn't create a `postgres` user, set `USERNAME` to your macOS username and `PASSWORD` to `''`.

---

### 2.5 Load the Project Tables

The project has a master SQL file (`SQL/setup_tables.sql`) with 180+ tables.  
The `sql/00_prerequisites.ipynb` notebook loads this automatically.

To load it manually via terminal:
```bash
psql -U postgres -d postgres -f /path/to/python_sql_pyspark/SQL/setup_tables.sql
```

To verify tables loaded:
```sql
-- Run in psql or any day notebook
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name
LIMIT 20;
```

---

## SECTION 3 — pgAdmin Setup

pgAdmin is a GUI for PostgreSQL — use it to browse tables, run queries visually, and inspect data.

---

### 3.1 Install pgAdmin

**Windows**  
pgAdmin is bundled with the PostgreSQL installer (Section 2.1).  
If you unchecked it, download separately: https://www.pgadmin.org/download/pgadmin-4-windows/  
Run the `.exe` installer → accept defaults.

**macOS**  
```bash
# Option 1 — Homebrew
brew install --cask pgadmin4

# Option 2 — Direct download
# https://www.pgadmin.org/download/pgadmin-4-macos/
# Download the .dmg → drag to Applications
```

**Ubuntu**
```bash
# Add pgAdmin apt repository
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] \
    https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" \
    > /etc/apt/sources.list.d/pgadmin4.list'

sudo apt update
sudo apt install -y pgadmin4-desktop
```

---

### 3.2 Connect pgAdmin to Your PostgreSQL Server

1. **Open pgAdmin** — a browser window opens (it's a web app served locally)
2. **Set a master password** when prompted — this is pgAdmin's own password, not PostgreSQL's
3. In the left panel: right-click **Servers** → **Register** → **Server...**
4. Fill in the **General** tab:
   - Name: `Local` (or any label you like)
5. Fill in the **Connection** tab:

   | Field | Value |
   |-------|-------|
   | Host name/address | `localhost` |
   | Port | `5432` |
   | Maintenance database | `postgres` |
   | Username | `postgres` |
   | Password | your PostgreSQL password |
   | Save password | check this box |

6. Click **Save** — the server appears in the left panel

---

### 3.3 Browse Tables in pgAdmin

```
Local
└── Databases
    └── postgres
        └── Schemas
            └── public
                └── Tables        ← all 180+ tables from setup_tables.sql
```

**To query a table:**  
Right-click any table → **View/Edit Data** → **All Rows**

**To run custom SQL:**  
Click the database → toolbar → **Query Tool** (or press `Alt+Shift+Q`)  
Paste your SQL → press `F5` to run

---

### 3.4 pgAdmin — Useful Settings

| Setting | Location | Recommended Value |
|---------|----------|------------------|
| Auto-save interval | File → Preferences → Query Tool → Auto Save | 5 minutes |
| Results grid font size | File → Preferences → Miscellaneous → Themes | Adjust to taste |
| Max rows returned | File → Preferences → Query Tool → Query Results | 1000 (default) |

---

## SECTION 4 — PySpark / Java Setup

PySpark requires Java. Install Java first, then PySpark is installed via `requirements.txt`.

---

### 4.1 Install Java

PySpark 3.5.x (included in `requirements.txt`) supports **Java 8, 11, or 17**.  
**Java 11 LTS** is recommended.

**Check if Java is already installed:**
```bash
java -version
echo $JAVA_HOME     # macOS/Linux
echo $env:JAVA_HOME # Windows PowerShell
```

If you see `openjdk version "11.x.x"` or `"17.x.x"` — skip to Section 4.2.

---

**Windows — Install Java 11**

1. Download Adoptium OpenJDK 11 from: https://adoptium.net/  
   Select: Java 11 (LTS) → Windows → x64 → `.msi`
2. Run the installer → accept defaults
3. When prompted **"Set JAVA_HOME variable"** → select **"Will be installed on local hard drive"**

Verify in a new PowerShell window:
```powershell
java -version
$env:JAVA_HOME
```

If `JAVA_HOME` is not set automatically, set it manually:  
Start → "Edit the system environment variables" → Environment Variables → System variables → New:
```
Variable name:  JAVA_HOME
Variable value: C:\Program Files\Eclipse Adoptium\jdk-11.0.xx-hotspot
```
Also add to `Path`: `%JAVA_HOME%\bin`

---

**macOS — Install Java 11**

```bash
brew install openjdk@11

# Add to ~/.zshrc
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 11)' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify
java -version
echo $JAVA_HOME
```

---

**Ubuntu — Install Java 11**

```bash
sudo apt update
sudo apt install -y openjdk-11-jdk

# Verify
java -version

# Set JAVA_HOME — add to ~/.bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo $JAVA_HOME
```

---

### 4.2 PySpark — Already in requirements.txt

`pyspark==3.5.6` is in `requirements.txt`. Running `pip install -r requirements.txt` (Section 1) installs it.

No separate Spark/Hadoop download needed — PySpark includes its own Spark binaries.

Verify after installing:
```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.master("local").getOrCreate()
print(spark.version)   # should print 3.5.6
spark.stop()
```

---

### 4.3 Windows — winutils (Optional Fix)

On Windows, PySpark may print a warning about missing `winutils.exe`.  
The `setLogLevel("ERROR")` call in every day notebook suppresses this warning.

To fully eliminate it:

1. Create folder: `C:\hadoop\bin`
2. Download `winutils.exe` for Hadoop 3.x from: https://github.com/cdarlint/winutils  
   Get file: `hadoop-3.3.5/bin/winutils.exe` → save to `C:\hadoop\bin\winutils.exe`
3. Set environment variable:  
   `HADOOP_HOME` = `C:\hadoop`  
   Add to `Path`: `%HADOOP_HOME%\bin`
4. Restart your terminal and JupyterLab

---

### 4.4 PySpark Day Notebook — Standard Header

Every PySpark day notebook starts with this block. Do not change it:

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, count, ...
from pyspark.sql.types import StructType, StructField, ...

spark = SparkSession.builder \
    .appName("Day01_...") \
    .master("local[*]") \
    .config("spark.sql.shuffle.partitions", "4") \
    .getOrCreate()

spark.sparkContext.setLogLevel("ERROR")
```

**`local[*]`** = use all CPU cores. For a slower machine use `local[2]`.  
**`shuffle.partitions=4`** = default 200 is wasteful for small local data.  
**`setLogLevel("ERROR")`** = hides INFO/WARN noise.

Spark UI (running job details) available at: `http://localhost:4040`

---

## SECTION 5 — Troubleshooting

### Python / pip

| Problem | Fix |
|---------|-----|
| `python: command not found` | Use `python3` instead, or install Python 3.10+ |
| `pip install` fails with permissions | Make sure the virtual environment is activated — never use `sudo pip` |
| Package version conflict during install | Upgrade pip first: `pip install --upgrade pip`, then retry |
| Notebook kernel shows as "Python 3" not "Python (myenv)" | Re-run: `python -m ipykernel install --user --name myenv --display-name "Python (myenv)"` |

### PostgreSQL

| Problem | Fix |
|---------|-----|
| `psql: command not found` | PostgreSQL `bin/` not in PATH — add it (Section 2.1 Step 3) |
| `connection refused` | Server not running — start it (see start commands in each OS section) |
| `password authentication failed` | Wrong password — check `PASSWORD` in the notebook connection cell |
| `role "postgres" does not exist` | macOS Homebrew: use your macOS username, or create the `postgres` user (Section 2.2) |
| `FATAL: peer authentication failed` | Ubuntu: change `peer` to `md5` in `pg_hba.conf` (Section 2.3) |
| `setup_tables.sql` not found | Set `setup_path` manually in `sql/00_prerequisites.ipynb` Cell E2 |

### pgAdmin

| Problem | Fix |
|---------|-----|
| pgAdmin won't open | It's a browser app — check if `http://localhost:5050` opens manually |
| "Unable to connect to server" | Verify PostgreSQL is running and password is correct in the connection settings |
| Tables not visible | Expand: Servers → Local → Databases → postgres → Schemas → public → Tables |

### PySpark

| Problem | Fix |
|---------|-----|
| `JAVA_HOME is not set` | Install Java 11 and set `JAVA_HOME` (Section 4.1) |
| `No module named 'pyspark'` | Virtual environment not activated, or `pip install -r requirements.txt` not run |
| Spark starts but is very slow | Normal on first run — JVM cold start. Takes 20–60s. Subsequent cells are faster. |
| Port 4040 already in use | Another SparkSession is running — `spark.stop()` it, or restart the kernel |
| `winutils.exe` warning on Windows | Either ignore it (suppressed by `setLogLevel`) or fix it (Section 4.3) |

---

## SECTION 6 — Daily Workflow

Once everything is set up, your daily routine is:

```
1. Open terminal / PowerShell

2. Activate virtual environment:
   Windows : myenv\Scripts\activate
   Mac/Linux: source myenv/bin/activate

3. Launch JupyterLab:
   jupyter lab

4. Open the day folder:
   python/day0X_topic/notebook.ipynb
   sql/day0X_topic/notebook.ipynb
   pyspark/day0X_topic/notebook.ipynb

5. Read notes.md first — then run the notebook cell by cell

6. Try solving Day problems before looking at solution cells
```

> **PostgreSQL** runs as a background service — it starts automatically at boot on Windows and Ubuntu.  
> On macOS Homebrew: `brew services start postgresql@16` once per login session, or enable auto-start with `brew services`.

---

## Quick Reference — Connection String

```python
# Used in every SQL day notebook — change PASSWORD only
USERNAME = "postgres"
PASSWORD = "postgres"    # <-- your password here
HOST     = "localhost"
PORT     = "5432"
DBNAME   = "postgres"

# ipython-sql magic
%sql postgresql://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DBNAME}
```

---

*Roadmap: Phase 1 — June 15 – June 30, 2026 · Phase 2 — July 1 – July 18, 2026*
