clc; clear;
addpath("after\exp1\")

fs = 250;

%% ========== LOAD EYES OPEN ==========
EEG = pop_loadset('filename','eo1.set');
EEG = eeg_checkset(EEG);
data = double(EEG.data);    % [channel × time]

% 取 O1 / O2
O1 = data(7, :);
O2 = data(8, :);

%% ========== 50 Hz NOTCH FILTER ==========
f0 = 50;
Q  = 50;
wo = f0/(fs/2);
bw = wo/Q;
[b,a] = iirnotch(wo,bw);

O1 = filtfilt(b,a,O1);
O2 = filtfilt(b,a,O2);
[b, a] = butter(2, 2*0.4 / fs, 'high');
O1 = filtfilt(b,a,O1);
O2 = filtfilt(b,a,O2);
%% ========== MANUAL PSD (V^2/Hz) ==========
N = length(O1);
f = (0:N-1)*(fs/N);

X1 = fft(O1);
X1(1) = 0;
X2 = fft(O2);
X2(1) = 0;
PSD_O1 = (abs(X1).^2) / (N*fs);
PSD_O2 = (abs(X2).^2) / (N*fs);

% 單邊頻譜
half = 1:floor(N/2);
f = f(half);
PSD_O1 = PSD_O1(half);
PSD_O2 = PSD_O2(half);

%% ========== EEG BAND LINES ==========
bandLines = [0.5 4 8 13 30 45];

%% ========== PLOT ==========
figure;
plot(f, PSD_O1,'b','LineWidth',1.5); hold on
plot(f, PSD_O2,'r','LineWidth',1.5);

for i = 1:length(bandLines)
    xline(bandLines(i),'k--');
end

xlim([0 125])
xlabel('Frequency (Hz)')
ylabel('Power Density (V^2/Hz)')
title('EEG Power Spectral Density with eyes open')
legend('O1','O2')
grid on
