clc; clear;
addpath("after\exp1\")

%% ================= 基本設定 =================
fs = 250;        % sampling rate
k  = 5;          % run number

%% ================= 讀取 Eyes OPEN =================
filename = sprintf('eo%d.set', k);
EEG = pop_loadset('filename', filename);
EEG = eeg_checkset(EEG);
data = double(EEG.data);    % [channel x time]

O1_open = data(7,:);
O2_open = data(8,:);

%% ================= 讀取 Eyes CLOSED =================
filename = sprintf('ec%d.set', k);
EEG = pop_loadset('filename', filename);
EEG = eeg_checkset(EEG);
data = double(EEG.data);

O1_closed = data(7,:);
O2_closed = data(8,:);

%% ================= 50 Hz Notch Filter =================
f0 = 50;
Q  = 50;
wo = f0/(fs/2);
bw = wo/Q;
[b_notch, a_notch] = iirnotch(wo, bw);

O1_open   = filtfilt(b_notch, a_notch, O1_open);
O2_open   = filtfilt(b_notch, a_notch, O2_open);
O1_closed = filtfilt(b_notch, a_notch, O1_closed);
O2_closed = filtfilt(b_notch, a_notch, O2_closed);

%% ================= 手寫 PSD（V^2/Hz） =================
N  = length(O1_open);
df = fs / N;
f  = (0:N-1) * df;

% FFT
X_O1o = fft(O1_open);
X_O2o = fft(O2_open);
X_O1c = fft(O1_closed);
X_O2c = fft(O2_closed);

% PSD 定義：|X(f)|^2 / (N * fs)
PSD_O1o = (abs(X_O1o).^2) / (N * fs);
PSD_O2o = (abs(X_O2o).^2) / (N * fs);
PSD_O1c = (abs(X_O1c).^2) / (N * fs);
PSD_O2c = (abs(X_O2c).^2) / (N * fs);

% 單邊頻譜
half = 1:floor(N/2);
f = f(half);

PSD_O1o = PSD_O1o(half);
PSD_O2o = PSD_O2o(half);
PSD_O1c = PSD_O1c(half);
PSD_O2c = PSD_O2c(half);

%% ================= Alpha Band Power (8–13 Hz) =================
idx_alpha = (f >= 8 & f <= 13);

P_O1_open   = sum(PSD_O1o(idx_alpha)) * df;
P_O2_open   = sum(PSD_O2o(idx_alpha)) * df;
P_O1_closed = sum(PSD_O1c(idx_alpha)) * df;
P_O2_closed = sum(PSD_O2c(idx_alpha)) * df;

% log(P)
logP_O1_open   = log10(P_O1_open   + eps);
logP_O2_open   = log10(P_O2_open   + eps);
logP_O1_closed = log10(P_O1_closed + eps);
logP_O2_closed = log10(P_O2_closed + eps);

%% ================= Dot Plot =================
figure; hold on

scatter(1, logP_O1_open,   80, 'r', 'filled')
scatter(2, logP_O2_open,   80, 'r', 'filled')
scatter(3, logP_O1_closed, 80, 'b', 'filled')
scatter(4, logP_O2_closed, 80, 'b', 'filled')

xlim([0.5 4.5])
set(gca,'XTick',1:4,...
        'XTickLabel',{'O1 open','O2 open','O1 closed','O2 closed'})

ylabel('log(P)')
title('Alpha bandpower with eyes open / eyes closed')
grid on
