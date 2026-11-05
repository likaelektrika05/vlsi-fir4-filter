% fir4_run_all.m -- run the full MATLAB flow and save all figures as PDF
close all;

fprintf('===== [1/3] Golden Reference Model =====\n');
fir4_golden('plot');

fprintf('\n===== [2/3] Test Vector Generation =====\n');
fir4_gen_vectors('plot');

fprintf('\n===== [3/3] Visualization Suite =====\n');
fir4_visualize;

fprintf('\n===== Saving figures as PDF =====\n');
figs = findall(0, 'Type', 'figure');
[~, order] = sort([figs.Number]);
figs = figs(order);
names = {'fig_golden', 'fig_vectors', 'fig1_freq_response', 'fig2_pole_zero', ...
         'fig3_impulse', 'fig4_chirp', 'fig5_spectrogram', 'fig6_quant_error'};
for i = 1:length(figs)
    if i <= length(names), fname = names{i};
    else, fname = sprintf('fig_extra_%d', i); end
    exportgraphics(figs(i), [fname '.pdf'], 'ContentType', 'vector');
    fprintf('  saved: %s.pdf\n', fname);
end
