#Sampling frequency: 250 Hz
import sqlite3
dbfile = r"C:\Users\L-JC (Harry)\Documents\作業\NUS neuron\Exp1\subj-3_ses-S001_task-eyes_closed_run-001_20260202_184157_eeg.db"

conn = sqlite3.connect(dbfile)

cursor = conn.cursor()
cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
tables = cursor.fetchall()
print(tables)

import pandas as pd

data_table = "data_5cc1b9b4-bd70-455d-a92c-7a37f2105b4d"

df = pd.read_sql(f'SELECT * FROM "{data_table}" LIMIT 5', conn)
print(df)
print(df.dtypes)


meta_table = "meta_5cc1b9b4-bd70-455d-a92c-7a37f2105b4d"

meta = pd.read_sql(f'SELECT * FROM "{meta_table}"', conn)
print(meta)
