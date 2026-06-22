# Retail Analytics DE Project — Setup Guide

Follow these steps **once** before opening any notebook.

---

## What you need installed before starting

- Python 3.9, 3.10, or 3.11 (3.11 recommended)
- PostgreSQL (running locally on port 5432)
- Java 8 or 11 (required by Spark)
- Jupyter Notebook or JupyterLab

---

## Step 1 — Check Java is installed

Open a terminal and run:

```
java -version
```

You should see something like `openjdk version "11.x.x"`.

**If Java is not installed:**

- **Windows:** Download from https://adoptium.net — choose Java 11, Windows x64 Installer. Run the installer.
- **macOS:** Run `brew install openjdk@11` in Terminal.
- **Linux:** Run `sudo apt install openjdk-11-jdk` (Ubuntu/Debian) or `sudo yum install java-11-openjdk` (RHEL/CentOS).

After installing, close and reopen your terminal, then run `java -version` again to confirm.

---

## Step 2 — Install Python packages

Open a terminal and run:

```
pip install pyspark sqlalchemy psycopg2-binary requests jupyter
```

Verify PySpark installed correctly:

```
python -c "import pyspark; print(pyspark.__version__)"
```

You should see a version number like `3.5.x`.

---

## Step 3 — Install the PostgreSQL JDBC jar (one-time)

PySpark uses JDBC to read and write PostgreSQL. You need to download one jar file and place it inside PySpark's `jars` folder.

Run the command for your operating system:

**Windows (PowerShell):**
```powershell
$jars = python -c "import pyspark,os; print(os.path.join(os.path.dirname(pyspark.__file__),'jars'))"
Invoke-WebRequest https://jdbc.postgresql.org/download/postgresql-42.7.3.jar -OutFile "$jars\postgresql-42.7.3.jar"
```

**macOS / Linux (Terminal):**
```bash
JARS=$(python -c "import pyspark,os; print(os.path.join(os.path.dirname(pyspark.__file__),'jars'))")
curl -L https://jdbc.postgresql.org/download/postgresql-42.7.3.jar -o "$JARS/postgresql-42.7.3.jar"
```

Verify it was placed correctly:

```
python -c "import pyspark,os,glob; p=os.path.join(os.path.dirname(pyspark.__file__),'jars','postgresql*.jar'); print(glob.glob(p))"
```

You should see a path like `.../pyspark/jars/postgresql-42.7.3.jar` printed.

> **If you have multiple Python versions** (e.g. system Python and a virtual environment), run the command above using the Python you will use as your Jupyter kernel. When in doubt, activate your virtual environment first, then run the command.

---

## Step 4 — Set up PostgreSQL

Make sure PostgreSQL is running and you know your username and password.

Test the connection:

```
psql -U postgres -c "SELECT version();"
```

If this works, PostgreSQL is ready. Note your username and password — you will need them in the next step.

---

## Step 5 — Edit your credentials in `config/db_config.py`

Open the file `config/db_config.py` in a text editor and update these five lines at the top:

```python
DB_USER = "postgres"      # your PostgreSQL username
DB_PASS = "your_pass"     # your PostgreSQL password
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "postgres"
```

Save the file. You only need to do this once — all notebooks import from this file automatically.

---

## Step 6 — Launch Jupyter and select the right kernel

Start Jupyter:

```
jupyter notebook
```

Open any notebook. Then in the menu bar:

**Kernel → Change Kernel → Python 3 (or the name of your virtual environment)**

Make sure you pick the Python where you installed PySpark in Step 2.

> **Important:** If you see an error like `Python in worker has different version than driver`, it means the wrong kernel is selected. Switch to the correct one and restart.

---

## Step 7 — Verify everything works

Open `day1/bronze_layer.ipynb` and run the first two cells (Setup and Start Spark).

You should see output like:

```
[db_config] PYSPARK_PYTHON  = C:\...\python.exe
[db_config] JAVA_HOME       = C:\Program Files\...
[db_config] Spark environment variables set.
[db_config] Spark 3.5.x ready — app: Day1_Bronze
[db_config] JDBC jar: C:\...\postgresql-42.7.3.jar
```

If you see this, setup is complete. Proceed with the notebooks in order:

```
day1 → day2 → day3 → day4
```

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `java.lang.ClassNotFoundException: org.postgresql.Driver` | JDBC jar missing | Repeat Step 3 with the correct Python |
| `Python in worker has different version than driver` | Wrong Jupyter kernel selected | Kernel → Change Kernel → pick the right Python |
| `PySpark is NOT installed in the current Python kernel` | Kernel uses a Python without PySpark | Switch kernel or run `pip install pyspark` in that Python |
| `Connection refused` (PostgreSQL) | PostgreSQL not running | Start PostgreSQL service |
| `authentication failed for user` | Wrong credentials | Update `DB_USER` / `DB_PASS` in `config/db_config.py` |
| `JAVA_HOME not set` or `java not found` | Java not installed or not on PATH | Install Java 11 (Step 1) and restart terminal |
