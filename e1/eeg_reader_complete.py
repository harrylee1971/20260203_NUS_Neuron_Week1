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
    """
    取得特定導極的資料
    
    參數:
        eeg_data: 完整的 EEG 資料陣列
        channel_names: 導極名稱列表
        channel_name: 要取得的導極名稱 (如 'F3')
        
    返回:
        該導極的資料陣列
    """
    idx = channel_names.index(channel_name)
    return eeg_data[idx, :]


def print_summary(eeg_data, time_stamps, channel_names, metadata):
    """列印資料摘要"""
    print("="*80)
    print("EEG 資料摘要")
    print("="*80)
    print(f"採樣頻率: {metadata['sampling_frequency']} Hz")
    print(f"資料長度: {metadata['n_samples']} 個樣本")
    print(f"記錄時間: {metadata['duration_seconds']:.2f} 秒")
    print(f"單位: {metadata['unit']}")
    print(f"\n導極列表: {', '.join(channel_names)}")
    print("\n各導極統計資訊:")
    print("-"*80)
    print(f"{'導極':<6} {'平均值':>12} {'標準差':>12} {'最小值':>12} {'最大值':>12}")
    print("-"*80)
    
    for i, ch_name in enumerate(channel_names):
        ch_data = eeg_data[i, :]
        print(f"{ch_name:<6} {ch_data.mean():12.2f} {ch_data.std():12.2f} "
              f"{ch_data.min():12.2f} {ch_data.max():12.2f}")
    print("="*80)


# ============================================================================
# 主程式範例
# ============================================================================

if __name__ == "__main__":
    # 載入資料
    db_path = r'C:\Users\L-JC (Harry)\Documents\作業\NUS neuron\Exp1\subj-3_ses-S001_task-eyes_closed_run-001_20260202_184157_eeg.db'
    eeg_data, time_stamps, channel_names, metadata = load_eeg_from_db(db_path)
    
    # 列印摘要
    print_summary(eeg_data, time_stamps, channel_names, metadata)
    
    # 示範如何存取個別導極的資料
    print("\n" + "="*80)
    print("使用範例")
    print("="*80)
    
    # 範例 1: 取得 F3 導極的資料
    f3_data = get_channel_data(eeg_data, channel_names, 'F3')
    print(f"\nF3 導極資料:")
    print(f"  形狀: {f3_data.shape}")
    print(f"  前 5 個值: {f3_data[:5]}")
    
    # 範例 2: 直接用索引存取
    print(f"\n使用索引存取各導極:")
    for i, ch_name in enumerate(channel_names):
        print(f"  {ch_name}: eeg_data[{i}, :] - 前3個值: {eeg_data[i, :3]}")
    
    # 範例 3: 將資料存成字典格式
    print(f"\n建立字典格式:")
    eeg_dict = {}
    for i, ch_name in enumerate(channel_names):
        eeg_dict[ch_name] = eeg_data[i, :]
    
    print(f"  可用導極: {list(eeg_dict.keys())}")
    print(f"  存取 O1: eeg_dict['O1'][:5] = {eeg_dict['O1'][:5]}")
    
    # 範例 4: 儲存資料
    # print(f"\n儲存資料:")
    # np.save(r'C:\Users\L-JC (Harry)\Documents\作業\NUS neuron\e1\eeg_all_8_channels.npy', eeg_data)
    # np.save(r'C:\Users\L-JC (Harry)\Documents\作業\NUS neuron\e1\eeg_timestamps.npy', time_stamps)
    
    # 個別儲存每個導極
    # for i, ch_name in enumerate(channel_names):
    #     np.save(rf'C:\Users\L-JC (Harry)\Documents\作業\NUS neuron\e1\eeg_{ch_name}.npy', eeg_data[i, :])
    
    print(f"  已儲存:")
    print(f"    - eeg_all_8_channels.npy (完整資料)")
    print(f"    - eeg_timestamps.npy (時間戳記)")
    print(f"    - eeg_F3.npy, eeg_F4.npy, ... (個別導極)")
    
    # 範例 5: 資料格式說明
    print(f"\n" + "="*80)
    print("資料格式說明")
    print("="*80)
    print(f"eeg_data 形狀: {eeg_data.shape}")
    print(f"  - 維度 0 (8): 代表 8 個導極")
    print(f"  - 維度 1 ({eeg_data.shape[1]}): 代表時間樣本數")
    print(f"\n資料型別: {eeg_data.dtype} (64位元浮點數)")
    print(f"數值範圍: {eeg_data.min():.2f} ~ {eeg_data.max():.2f} microvolts")
    
    # 範例 6: 計算一些簡單的特徵
    print(f"\n簡單特徵計算:")
    print(f"  全部資料的平均: {eeg_data.mean():.2f} microvolts")
    print(f"  前1秒的資料 (250個樣本):")
    first_second = eeg_data[:, :250]
    print(f"    平均: {first_second.mean():.2f} microvolts")
    
    print("\n" + "="*80)
    print("程式執行完成!")
    print("="*80)


from scipy.io import savemat
import os

# ==========================================================
# 1. 將資料轉成 (n_samples, 8)
# ==========================================================
# 原本 eeg_data: (8, n_samples)
eeg_mat = eeg_data.T   # → (n_samples, 8)

print("EEG matrix shape for MAT:", eeg_mat.shape)

# ==========================================================
# 2. 準備要存進 MAT 的內容
# ==========================================================
mat_dict = {
    'EEG': eeg_mat,                         # 主資料 (time × channels)
    'channel_names': np.array(channel_names, dtype=object),
    'sfreq': metadata['sampling_frequency'],
    'unit': metadata['unit'],
    'n_channels': metadata['n_channels'],
    'n_samples': metadata['n_samples']
}

# ==========================================================
# 3. 儲存成 .mat
# ==========================================================
mat_path = r'C:\Users\L-JC (Harry)\Documents\作業\NUS neuron\e1\eeg_8ch_time_by_channel.mat'
savemat(mat_path, mat_dict)

print(f"MAT file saved to:\n{mat_path}")
