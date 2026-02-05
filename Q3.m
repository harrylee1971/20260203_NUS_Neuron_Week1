clc; clear;
addpath("after\exp1\")
fs = 250;
k = 5;
%% ========== LOAD EYES OPEN ==========
filename = sprintf('eo%d.set', k);
EEG = pop_loadset('filename',filename);
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
[b_alpha,a_alpha] = butter(4,[8 13]/(fs/2),'bandpass');

O1_o = filtfilt(b_alpha,a_alpha,O1);
O2_o = filtfilt(b_alpha,a_alpha,O2);


%% Second Part

addpath("after\exp1\")
fs = 250;

%% ========== LOAD EYES OPEN ==========

filename = sprintf('ec%d.set', k);
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
O1_c = filtfilt(b_alpha,a_alpha,O1);
O2_c = filtfilt(b_alpha,a_alpha,O2);
%% Plot O1, O2

%% ========== Plot O1 / O2 (Alpha band, Time Domain) ==========

t1 = (0:length(O1_o)-1)/fs;   % time axis (s)
               % representative 5 seconds
t2 = (0:length(O1_c)-1)/fs;

%% ========== Compute RMS (alpha band, time domain) ==========
RMS_O1_open   = sqrt(mean(O1_o.^2));
RMS_O2_open   = sqrt(mean(O2_o.^2));
RMS_O1_closed = sqrt(mean(O1_c.^2));
RMS_O2_closed = sqrt(mean(O2_c.^2));

%% ========== Dot Plot ==========
figure; hold on

% x positions
x = [1 2 3 4];

% y values
y = [RMS_O1_open, RMS_O2_open, RMS_O1_closed, RMS_O2_closed];

% plot dots
scatter(1, RMS_O1_open,   80, 'r', 'filled')
scatter(2, RMS_O2_open,   80, 'r', 'filled')
scatter(3, RMS_O1_closed, 80, 'b', 'filled')
scatter(4, RMS_O2_closed, 80, 'b', 'filled')

% axis settings
xlim([0.5 4.5])
set(gca,'XTick',x)
set(gca,'XTickLabel',{'O1 open','O2 open','O1 closed','O2 closed'})

ylabel('RMS (\muV)')
title('Alpha band RMS with eyes open / eyes closed')
grid on
