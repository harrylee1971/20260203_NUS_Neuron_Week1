import sqlite3
import numpy as np
import pandas as pd
from io import BytesIO
import matplotlib.pyplot as plt
import os

# ===============================
# 1. 開啟資料庫
# ===============================
dbfile = r"C:\Users\L-JC (Harry)\Documents\作業\NUS neuron\Exp1\subj-3_ses-S001_task-eyes_open_run-001_20260202_184058_eeg.db"
assert os.path.exists(dbfile), "DB file not found"

conn = sqlite3.connect(dbfile)

DATA_TABLE = "data_5cc1b9b4-bd70-455d-a92c-7a37f2105b4d"
META_TABLE = "meta_5cc1b9b4-bd70-455d-a92c-7a37f2105b4d"

# ===============================
# 2. 讀 meta（只拿 channel order & sf）
# ===============================
meta = pd.read_sql(f'SELECT * FROM "{META_TABLE}"', conn)

sfreq = float(meta["sf"].iloc[0])
all_channels = meta["channels"].iloc[0].split(",")

print("Sampling rate:", sfreq)
print("All channels:", all_channels)

# 找 O1 的 index（完全不靠「前 8 個」）
if "O1" not in all_channels:
    raise RuntimeError("O1 not found in meta.channels")

o1_idx = all_channels.index("O1")
print("O1 channel index:", o1_idx)

# ===============================
# 3. 只讀「第一個 segment」
# ===============================
df = pd.read_sql(
    f'SELECT data FROM "{DATA_TABLE}" LIMIT 1',
    conn
)

blob = df["data"].iloc[0]
arr = np.load(BytesIO(blob))   # shape: (time, channels)

print("Segment shape:", arr.shape)

# ===============================
# 4. 取出 O1
# ===============================
o1 = arr[:, o1_idx]             # shape: (time,)
t = np.arange(o1.size) / sfreq  # seconds

# ===============================
# 5. 畫 O1（例如前 20 秒）
# ===============================
sec_to_show = 1000
n_show = int(sec_to_show * sfreq)

plt.figure()
plt.plot(t[:n_show], o1[:n_show])
plt.xlabel("Time (s)")
plt.ylabel("Amplitude (raw unit)")
plt.title("O1 raw signal (first segment, first 20s)")
plt.tight_layout()
plt.show()

# ===============================
# 6. 印基本統計（輔助判斷）
# ===============================
print("O1 stats:")
print("  min :", float(np.min(o1)))
print("  max :", float(np.max(o1)))
print("  mean:", float(np.mean(o1)))
print("  std :", float(np.std(o1)))
print("  finite ratio:", float(np.isfinite(o1).mean()))
