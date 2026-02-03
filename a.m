for i = 1:8
    EEG(:, i) = EEG(:, i) - mean(EEG(:, i));
end

for i = 1:8
    subplot(8, 1, i)
    plot(EEG(:, i))
end