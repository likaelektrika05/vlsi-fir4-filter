% fir4_gen_vectors.m -- generate stimulus + expected hex files for tb_fir4
function fir4_gen_vectors(varargin)
    shift = 3;
    stim = {}; labels = {};

    stim{end+1} = [64 zeros(1,19)];             labels{end+1} = 'Impulse';
    stim{end+1} = [zeros(1,4) 127*ones(1,20)];  labels{end+1} = 'Step';
    stim{end+1} = -128:127;                     labels{end+1} = 'Ramp';
    n = 0:63;
    stim{end+1} = round(100*sin(2*pi*n/32));    labels{end+1} = 'Sin (f=Fs/32, passes)';
    stim{end+1} = round(100*sin(2*pi*n/4));     labels{end+1} = 'Sin (f=Fs/4, attenuated)';
    t = linspace(0, 1, 128);
    s = round(100*sin(2*pi*(0.5 + 60*t).*t));
    stim{end+1} = max(min(s, 127), -128);       labels{end+1} = 'Chirp (DC to Nyquist)';
    rng(42);
    stim{end+1} = randi([-128 127], 1, 64);     labels{end+1} = 'Random';
    stim{end+1} = [127*ones(1,8) -128*ones(1,8) repmat([127 -128], 1, 8)];
    labels{end+1} = 'Saturation corners';

    % Join all patterns with 8 zeros between them (lets the pipeline flush)
    all_x = [];
    for k = 1:length(stim)
        all_x = [all_x stim{k} zeros(1,8)];
    end
    all_y = fir4_rtl_model(all_x, shift);

    write_hex_signed('../tb/stim_vectors.hex',    all_x, 8);
    write_hex_signed('../tb/expected_vectors.hex', all_y, 11);

    fprintf('\n=== fir4 Test Vector Generator ===\n');
    fprintf('  Patterns     : %d\n', length(stim));
    fprintf('  Total samples: %d\n', length(all_x));
    for k = 1:length(stim)
        fprintf('  %d. %-28s %4d samples\n', k, labels{k}, length(stim{k}));
    end

    if nargin > 0 && strcmpi(varargin{1}, 'plot')
        figure('Name', 'fir4 test vectors');
        subplot(2,1,1); plot(all_x); title('Stimulus x[n]');
        subplot(2,1,2); plot(all_y); title('Expected y[n] (RTL model)');
    end
end

% Same hardware-equivalent model as in fir4_golden.m
function y = fir4_rtl_model(x, shift)
    N = length(x); y = zeros(1, N); d = zeros(1, 4);
    for k = 1:N
        d = [x(k) d(1:3)];
        sum_a  = d(1) + d(4);
        sum_b  = d(2) + d(3);
        prod_b = sum_b * 3;
        y(k) = floor((sum_a + prod_b) / 2^shift);
    end
end

% Write signed values as two's-complement hex, one per line
function write_hex_signed(filename, data, nbits)
    fid = fopen(filename, 'w');
    if fid < 0, error('Cannot open %s', filename); end
    mask = 2^nbits - 1;
    fmt = ['%0' num2str(ceil(nbits/4)) 'X\n'];
    for i = 1:length(data)
        val = data(i);
        if val < 0, val = val + 2^nbits; end
        fprintf(fid, fmt, bitand(val, mask));
    end
    fclose(fid);
end