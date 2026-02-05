addpath("e1")
load("eo1.mat")
abc(EEG, sfreq);
load("eo2.mat")
abc(EEG, sfreq);
load("eo3.mat")
abc(EEG, sfreq);
load("eo4.mat")
abc(EEG, sfreq);
load("eo5.mat")
abc(EEG, sfreq);
%%
function abc(EEG, sfreq)
    fs = sfreq;
    eeg_fft = zeros(length(EEG), 8);
    [b, k] = butter(2, 2*0.5/fs, 'high');
    EEG = filtfilt(b, k, EEG);
    for i = 1:8
        eeg_fft(:, i) = fft(EEG(:, i));
    end
    figure;
    eeg_fft = eeg_fft(:, 8);
    eeg_fft(1) = 0;
    eeg_fft(eeg_fft(:,1) >= 15*1e4, 1) = 0;
    y = (abs(eeg_fft)/length(eeg_fft)).^2;
    y(y(:, 1) > 15*1e4, 1) = 0;
    plot(((1:length(eeg_fft)) - 1) / length(eeg_fft) * fs, y)
    xlim([0 fs/2])
end