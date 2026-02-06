clc; clear;
addpath('after/exp2')

%% ===== 設定 =====
bands.alpha = [8 13];
bands.beta  = [13 30];

tasks = {'f_tap_rest','f_tap_left','f_tap_right','f_tap_both'}; % 1=rest,2=left,3=right,4=both
nRun = 5;

xlabels = {'C3 left tap','C4 left tap','C3 right tap','C4 right tap','C3 both tap','C4 both tap'};
x = 1:6;
%% =================

band_list = {'alpha','beta'};

for bb = 1:length(band_list)

    band_name = band_list{bb};
    band = bands.(band_name);

    % 先存 bandpower：rows=run, cols=task (rest/left/right/both)
    P_C3 = zeros(nRun, 4);
    P_C4 = zeros(nRun, 4);

    %% ===== 計算每個 task、每個 run 的 bandpower =====
    for t = 1:4
        for k = 1:nRun

            EEG = pop_loadset('filename', sprintf('t%d.set', k), ...
                              'filepath', fullfile('after/exp2', tasks{t}));
            EEG = eeg_checkset(EEG);

            data = double(EEG.data);
            fs = EEG.srate;

            C3 = data(3, :);
            C4 = data(4, :);

            [b, a] = butter(4, band/(fs/2), 'bandpass');
            C3f = filtfilt(b, a, C3);
            C4f = filtfilt(b, a, C4);

            P_C3(k, t) = mean(C3f.^2);
            P_C4(k, t) = mean(C4f.^2);
        end
    end

    %% ===== 以 rest 當 baseline：log(P_task) - log(P_rest) =====
    dC3_left  = log(P_C3(:,2)) - log(P_C3(:,1)); % 5x1
    dC4_left  = log(P_C4(:,2)) - log(P_C4(:,1));
    dC3_right = log(P_C3(:,3)) - log(P_C3(:,1));
    dC4_right = log(P_C4(:,3)) - log(P_C4(:,1));
    dC3_both  = log(P_C3(:,4)) - log(P_C3(:,1));
    dC4_both  = log(P_C4(:,4)) - log(P_C4(:,1));

    % 組成 5x6：每一欄是一個類別、每一列是一個 run
    dP = [dC3_left, dC4_left, dC3_right, dC4_right, dC3_both, dC4_both];  % (5 x 6)

    %% ===== Dot plot：每個類別 5 個點，X=1..6 =====
    figure; hold on;

    for i = 1:6
        scatter(ones(nRun,1)*x(i), dP(:, i), 60, 'filled');
    end

    set(gca, 'XTick', x, 'XTickLabel', xlabels);
    ylabel('log(P) - log(P_{rest})');
    title(['Lateralization of ', band_name, ' bandpower under different finger tapping conditions']);
    grid on;

end
