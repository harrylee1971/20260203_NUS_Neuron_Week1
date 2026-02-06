clc; clear;
addpath('after/exp2')

%% ===== 設定 =====
tasks = {'f_tap_rest','f_tap_left','f_tap_right','f_tap_both'};
task_labels = {'rest','left tap','right tap','both tap'};
nTask = length(tasks);
nRun = 5;
%% =================

% 儲存 beta bandpower
P_C3 = zeros(nRun, nTask);
P_C4 = zeros(nRun, nTask);

for t = 1:nTask
    for k = 1:nRun

        %% ===== Load EEG =====
        folderPath = fullfile('after/exp2', tasks{t});
        filename = sprintf('t%d.set', k);

        EEG = pop_loadset('filename', filename, 'filepath', folderPath);
        EEG = eeg_checkset(EEG);

        data = double(EEG.data);
        fs = EEG.srate;

        C3 = data(3, :);
        C4 = data(4, :);

        %% ===== Beta bandpass filter (13–30 Hz) =====
        [b, a] = butter(4, [13 30]/(fs/2), 'bandpass');
        C3_beta = filtfilt(b, a, C3);
        C4_beta = filtfilt(b, a, C4);

        %% ===== Beta bandpower =====
        % band-limited power = mean squared amplitude
        P_C3(k, t) = mean(C3_beta.^2);
        P_C4(k, t) = mean(C4_beta.^2);

    end
end

%% ===== Dot Plot =====
figure; hold on;

x = 1:nTask;
offset = 0.12;   % 左右錯開，避免 C3/C4 重疊

for t = 1:nTask
    scatter(ones(nRun,1)*(x(t)-offset), log(P_C3(:,t)), ...
        60, 'b', 'filled');
    scatter(ones(nRun,1)*(x(t)+offset), log(P_C4(:,t)), ...
        60, 'r', 'filled');
end

set(gca,'XTick',x,'XTickLabel',task_labels);
xlabel('Task');
ylabel('log(P)');
title('beta bandpower across finger tapping tasks');
legend('C3','C4','Location','best');
grid on;
        