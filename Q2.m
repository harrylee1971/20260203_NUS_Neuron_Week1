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

O1 = filtfilt(b, a, O1);
O2 = filtfilt(b, a, O2);
%% Bandpass filter 8-13Hz
[Ha, Hb] = butter(2, 2*8/fs, 'high');
[La, Lb] = butter(2, 2*13/fs, 'low');
O1 = filtfilt(Ha, Hb, O1);
O1 = filtfilt(La, Lb, O1);
O2 = filtfilt(Ha, Hb, O2);
O2 = filtfilt(La, Lb, O2);  %Because of Linear filter 
O1_o = O1;
O2_o = O2;
%% Second Part

addpath("after\exp1\")
fs = 250;

%% ========== LOAD EYES OPEN ==========
EEG = pop_loadset('filename','ec1.set');
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
%% Bandpass filter 8-13Hz
[Ha, Hb] = butter(2, 2*8/fs, 'high');
[La, Lb] = butter(2, 2*13/fs, 'low');
O1 = filtfilt(Ha, Hb, O1);
O1 = filtfilt(La, Lb, O1);
O2 = filtfilt(Ha, Hb, O2);
O2 = filtfilt(La, Lb, O2);  %Because of Linear filter 
O1_c = O1;
O2_c = O2;
%% Plot O1, O2

%% ========== Plot O1 / O2 (Alpha band, Time Domain) ==========

t1 = (0:length(O1_o)-1)/fs;   % time axis (s)
               % representative 5 seconds
t2 = (0:length(O1_c)-1)/fs;
figure;

% -------- Eyes OPEN --------
subplot(2,1,1)
plot(t1, O1_o, 'r', 'LineWidth', 1.2); hold on
plot(t1, O2_o, 'b', 'LineWidth', 1.2);
ylim([-50 50])
xlim([8 13])
xlabel('Time (s)')
ylabel('EEG Amplitude (\muV)')
title('Alpha band (8–13 Hz) EEG with eyes open')
legend('O1','O2')
grid on

% -------- Eyes CLOSED --------
subplot(2,1,2)
plot(t2, O1_c, 'r', 'LineWidth', 1.2); hold on
plot(t2, O2_c, 'b', 'LineWidth', 1.2);
ylim([-50 50])
xlim([8 13])
xlabel('Time (s)')
ylabel('EEG Amplitude (\muV)')
title('Alpha band (8–13 Hz) EEG with eyes closed')
legend('O1','O2')
grid on

