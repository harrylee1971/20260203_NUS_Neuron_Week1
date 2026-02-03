"""
EEG 資料庫讀取與還原程式
======================================
此程式從 SQLite 資料庫中讀取 EEG 資料並還原成 NumPy 陣列格式

資料庫結構:
- 資料以 NumPy .npy 格式儲存在 BLOB 欄位中
- 8個 EEG 導極: F3, F4, C3, C4, P3, P4, O1, O2
- 採樣頻率: 250 Hz
- 單位: microvolts
"""

import sqlite3
import numpy as np
import io
import os
from scipy.io import savemat


def load_eeg_from_db(db_path):
    """
    從資料庫載入 EEG 資料
    
    參數:
        db_path: 資料庫檔案路徑
        
    返回:
        eeg_data: numpy array, shape=(8, n_samples), 8個導極的資料
        time_stamps: numpy array, shape=(n_samples,), 時間戳記
        channel_names: list, 8個導極的名稱
        metadata: dict, 包含採樣頻率等資訊
    """
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # 讀取 meta 資料
    cursor.execute("SELECT * FROM 'meta_5cc1b9b4-bd70-455d-a92c-7a37f2105b4d';")
    meta = cursor.fetchone()
    
    channels = meta[0].split(',')
    channels_type = meta[1].split(',')
    channels_unit = meta[2].split(',')
    sampling_freq = meta[3]
    
    # 找出 EEG 通道
    eeg_channels = []
    eeg_indices = []
    for i, (ch, ch_type) in enumerate(zip(channels, channels_type)):
        if ch_type == 'EEG':
            eeg_channels.append(ch)
            eeg_indices.append(i)
    
    # 讀取所有資料區塊
    cursor.execute("SELECT data, time FROM 'data_5cc1b9b4-bd70-455d-a92c-7a37f2105b4d';")
    all_data = cursor.fetchall()
    
    # 解析並合併資料
    all_eeg_data = []
    all_time_data = []
    
    for data_blob, time_blob in all_data:
        data = np.load(io.BytesIO(data_blob))
        time = np.load(io.BytesIO(time_blob))
        
        eeg_data = data[eeg_indices, :]
        all_eeg_data.append(eeg_data)
        all_time_data.append(time)
    
    # 合併所有區塊
    concatenated_eeg = np.concatenate(all_eeg_data, axis=1)
    concatenated_time = np.concatenate(all_time_data)
    
    metadata = {
        'sampling_frequency': sampling_freq,
        'unit': 'microvolts',
        'channel_names': eeg_channels,
        'n_channels': len(eeg_channels),
        'n_samples': concatenated_eeg.shape[1],
        'duration_seconds': concatenated_time[-1] - concatenated_time[0]
    }
    
    conn.close()
    
    return concatenated_eeg, concatenated_time, eeg_channels, metadata


def get_channel_data(eeg_data, channel_names, channel_name):
    idx = channel_names.index(channel_name)
    return eeg_data[idx, :]


def print_summary(eeg_data, time_stamps, channel_names, metadata):
    print("="*80)
    print("EEG 資料摘要")
    print("="*80)
    print(f"採樣頻率: {metadata['sampling_frequency']} Hz")
    print(f"資料長度: {metadata['n_samples']} 個樣本")
    print(f"記錄時間: {metadata['duration_seconds']:.2f} 秒")
    print(f"單位: {metadata['unit']}")
    print(f"\n導極列表: {', '.join(channel_names)}")
    print("="*80)


# ============================================================================
# 主程式（加入 for 迴圈版本）
# ============================================================================
if __name__ == "__main__":

    db_dir = r'C:\Users\L-JC (Harry)\Documents\作業\NUS neuron\Exp1'
    out_dir = r'C:\Users\L-JC (Harry)\Documents\作業\NUS neuron\e1'
    os.makedirs(out_dir, exist_ok=True)

    db_files = [f for f in os.listdir(db_dir) if f.endswith('.db')]

    print(f"找到 {len(db_files)} 個 db 檔案")

    for db_file in db_files:
        print("\n" + "="*80)
        print(f"處理檔案: {db_file}")

        db_path = os.path.join(db_dir, db_file)

        eeg_data, time_stamps, channel_names, metadata = load_eeg_from_db(db_path)

        # 原本 eeg_data: (8, n_samples)
        eeg_mat = eeg_data.T   # → (n_samples, 8)

        print("EEG matrix shape for MAT:", eeg_mat.shape)

        mat_dict = {
            'EEG': eeg_mat,
            'channel_names': np.array(channel_names, dtype=object),
            'sfreq': metadata['sampling_frequency'],
            'unit': metadata['unit'],
            'n_channels': metadata['n_channels'],
            'n_samples': metadata['n_samples']
        }

        mat_name = os.path.splitext(db_file)[0] + '_8ch_time_by_channel.mat'
        mat_path = os.path.join(out_dir, mat_name)

        savemat(mat_path, mat_dict)

        print(f"MAT file saved to:\n{mat_path}")

    print("\n" + "="*80)
    print("全部 db 處理完成")
    print("="*80)
