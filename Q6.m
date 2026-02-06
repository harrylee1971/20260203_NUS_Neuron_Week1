clc; clear;
addpath('after/exp2')

%% ===== 使用者設定 =====
tasks = {'f_tap_rest','f_tap_left','f_tap_right','f_tap_both'};
k = 1;              % t1 ~ t5
plot_sec = 5;       % 5-second span
%% =====================

%% ===== 建立輸出資料夾 =====
save_dir = fullfile('Result_P','Q6');
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

    %% ===== Alpha bandpass filter (8–13 Hz) =====
    f_low = 8;
    f_high = 13;
    [b, a] = butter(4, [f_low f_high]/(fs/2), 'bandpass');

    C3_alpha = filtfilt(b, a, C3);
    C4_alpha = filtfilt(b, a, C4);

    %% ===== 擷取 5 秒資料 =====
    N = length(C3_alpha);
    seg_len = plot_sec * fs;

    start_idx = floor(N/2);
    idx = start_idx : start_idx + seg_len - 1;

    t_axis = (0:seg_len-1) / fs;

    %% ===== Plot =====
    fig = figure('Visible','off');   % 不跳出視窗（交作業很乾淨）
    plot(t_axis, C3_alpha(idx), 'b', 'LineWidth', 1); hold on;
    plot(t_axis, C4_alpha(idx), 'r', 'LineWidth', 1);

    xlabel('Time (s)');
    ylabel('Amplitude (\muV)');
    title(['Alpha band EEG (8–13 Hz) - ', strrep(task,'_',' ')]);
    legend('C3','C4');
    grid on;

    %% ===== Save figure =====
    save_name = sprintf('Q6_%s_t%d.png', task, k);
    save_path = fullfile(save_dir, save_name);
    saveas(fig, save_path);

    close(fig);   % 關閉 figure，避免一次開太多

end
