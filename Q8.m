clc; clear;
addpath('after/exp2')

%% ===== 使用者設定 =====
tasks = {'f_tap_rest','f_tap_left','f_tap_right','f_tap_both'};
k = 1;                 % t1 ~ t5
plot_sec = 2;          % 2-second span (題目要求)
%% =====================

%% ===== 建立輸出資料夾（可選）=====
save_dir = fullfile('Result_P','Q8');
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

for t = 1:length(tasks)

    task = tasks{t};

    %% ===== Load EEG =====
    folderPath = fullfile('after/exp2', task);
    filename = sprintf('t%d.set', k);

    EEG = pop_loadset('filename', filename, 'filepath', folderPath);
    EEG = eeg_checkset(EEG);

    data = double(EEG.data);
    fs = EEG.srate;

    C3 = data(3, :);
    C4 = data(4, :);

    %% ===== Beta bandpass filter (13–30 Hz) =====
    f_low = 13;
    f_high = 30;
    [b, a] = butter(4, [f_low f_high]/(fs/2), 'bandpass');

    C3_beta = filtfilt(b, a, C3);
    C4_beta = filtfilt(b, a, C4);

    %% ===== 擷取 2 秒資料 =====
    N = length(C3_beta);
    seg_len = plot_sec * fs;

    % 取中段當 representative segment（避開開頭/結尾 artifact）
    start_idx = floor(N/2);

    % 避免越界（很重要，防止某些檔案太短）
    if start_idx + seg_len - 1 > N
        start_idx = N - seg_len + 1;
    end
    if start_idx < 1
        start_idx = 1;
    end

    idx = start_idx : start_idx + seg_len - 1;
    t_axis = (0:seg_len-1) / fs;

    %% ===== Plot =====
    fig = figure('Visible','off');   % 不跳視窗
    plot(t_axis, C3_beta(idx), 'b', 'LineWidth', 1); hold on;
    plot(t_axis, C4_beta(idx), 'r', 'LineWidth', 1);

    xlabel('Time (s)');
    ylabel('Amplitude (\muV)');
    title(['Beta band EEG (13–30 Hz) - ', strrep(task,'_',' ')]);
    legend('C3','C4');
    grid on;

    %% ===== Save figure =====
    save_name = sprintf('Q7_%s_t%d.png', task, k);
    save_path = fullfile(save_dir, save_name);
    saveas(fig, save_path);
    close(fig);

end
