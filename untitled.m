addpath("after/exp1/")
EEG_raw = pop_loadset('filename', 'ec1.set');
EEG_raw = eeg_checkset(EEG_raw);
EEG = EEG_raw.data.';