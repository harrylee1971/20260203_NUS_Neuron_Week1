clc; clear;
addpath('after/exp2')

%% ===== 使用者只改這兩行 =====
task = 'f_tap_both';   % 'f_tap_rest' | 'f_tap_left' | 'f_tap_right' | 'f_tap_both'
k = 1;                 % t1 ~ t5
%% ============================

% C3 -> 3, C4 -> 4
folderPath = fullfile('after/exp2', task);
filename = sprintf('t%d.set', k);

EEG = pop_loadset('filename', filename, 'filepath', folderPath);
EEG = eeg_checkset(EEG);

data = double(EEG.data);
fs = EEG.srate;

C3 = data(3, :);
C4 = data(4, :);

%% ===== 50 Hz Notch Filter =====
f0 = 50;
Q  = 50;
wo = f0/(fs/2);
bw = wo/Q;
[b, a] = iirnotch(wo, bw);

C3 = filtfilt(b, a, C3);
C4 = filtfilt(b, a, C4);

%% ===== 手寫 PSD（不用任何 function） =====
N = length(C3);
Nfft = 2^nextpow2(N);

% FFT
X3 = fft(C3, Nfft);
X4 = fft(C4, Nfft);

% 頻率軸
f = (0:Nfft/2-1) * fs / Nfft;

% Power Spectral Density
PSD_C3 = (1/(fs*N)) * abs(X3).^2;
PSD_C4 = (1/(fs*N)) * abs(X4).^2;

% Single-sided spectrum
PSD_C3 = PSD_C3(1:Nfft/2);
PSD_C4 = PSD_C4(1:Nfft/2);

%% ===== Plot PSD =====
figure;
plot(f, PSD_C3, 'b', 'LineWidth', 1.2); hold on;
plot(f, PSD_C4, 'r', 'LineWidth', 1.2);

% 頻帶邊界（虛線）
xline(0.5, '--k');
xline(4,   '--k');
xline(8,   '--k');
xline(13,  '--k');
xline(30,  '--k');

xlim([0 50])
xlabel('Frequency (Hz)');
ylabel('Power Density');

title(['EEG Power Spectral density of ', strrep(task,'_',' ')]);
legend('C3','C4');

grid on;
