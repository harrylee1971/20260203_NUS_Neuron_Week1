clc; clear;
addpath('after/exp2')

%% ===== 設定 =====
tasks = {'f_tap_rest','f_tap_left','f_tap_right','f_tap_both'};
task_labels = {'rest','left tap','right tap','both tap'};
nTask = length(tasks);
nRun = 5;
%% =================

% 儲存 power
P_C3 = zeros(nRun, nTask);
P_C4 = zeros(nRun, nTask);

for t = 1:nTask
    for k = 1:nRun

        % ===== Load EEG =====
        folderPath = fullfile('after/exp2', tasks{t});
        filename = sprintf('t%d.set', k);

        EEG = pop_loadset('filename', filename, 'filepath', folderPath);
        EEG = eeg_checkset(EEG);

        data = double(EEG.data);
        fs = EEG.srate;

        C3 = data(3, :);
        C4 = data(4, :);

        % ===== Alpha bandpass filter (8–13 Hz) =====
        [b, a] = butter(4, [8 13]/(fs/2), 'bandpass');
        C3_alpha = filtfilt(b, a, C3);
        C4_alpha = filtfilt(b, a, C4);

        % ===== Alpha bandpower =====
        P_C3(k, t) = mean(C3_alpha.^2);
        P_C4(k, t) = mean(C4_alpha.^2);

    end
end

% ===== Dot Plot =====
figure; hold on;

x = 1:nTask;
offset = 0.12;   % 左右錯開避免重疊

for t = 1:nTask
    scatter(ones(nRun,1)*(x(t)-offset), log(P_C3(:,t)), ...
        60, 'b', 'filled');
    scatter(ones(nRun,1)*(x(t)+offset), log(P_C4(:,t)), ...
        60, 'r', 'filled');
end

set(gca,'XTick',x,'XTickLabel',task_labels);
xlabel('Task'); 
ylabel('log(P)');
title('alpha bandpower across finger tapping tasks');
legend('C3','C4','Location','best');
grid on;
