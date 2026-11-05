% fir4_golden.m -- Golden reference model for the 4-tap FIR [1 3 3 1]/8
function fir4_golden(varargin)
    do_plot = nargin > 0 && strcmpi(varargin{1}, 'plot');

    coeffs  = [1 3 3 1];        % binomial low-pass coefficients
    norm_f  = sum(coeffs);      % 8
    shift   = log2(norm_f);     % 3  (divide by 8 = shift right by 3)
    b_exact = coeffs / norm_f;  % [0.125 0.375 0.375 0.125]

    % --- Test 1: impulse ---
    x_imp = [64 zeros(1,7)];
    ye_imp = filter(b_exact, 1, x_imp);
    yr_imp = fir4_rtl_model(x_imp, shift);
    print_table('Impulse (x[0]=64)', x_imp, ye_imp, yr_imp);

    % --- Test 2: step ---
    x_step = 127 * ones(1, 12);
    ye_step = filter(b_exact, 1, x_step);
    yr_step = fir4_rtl_model(x_step, shift);
    print_table('Step (x=127)', x_step, ye_step, yr_step);

    % --- Test 3: sinusoid ---
    n = 0:31;
    x_sin = round(100 * sin(2*pi*n/16));
    ye_sin = filter(b_exact, 1, x_sin);
    yr_sin = fir4_rtl_model(x_sin, shift);
    print_table('Sinusoid (period 16)', x_sin, ye_sin, yr_sin);

    if do_plot
        figure('Name', 'fir4 golden: exact vs RTL');
        subplot(3,1,1); stem(0:7, ye_imp); hold on; stem(0:7, yr_imp, 'x');
        title('Impulse'); legend('exact', 'RTL');
        subplot(3,1,2); plot(0:11, ye_step, '-o'); hold on; plot(0:11, yr_step, '-x');
        title('Step'); legend('exact', 'RTL');
        subplot(3,1,3); plot(n, x_sin, 'Color', [0.6 0.6 0.6]); hold on;
        plot(n, ye_sin, 'b'); plot(n, yr_sin, 'r--');
        title('Sinusoid'); legend('input', 'exact', 'RTL');
    end
end

% Hardware-equivalent model: same order of operations as fir4.sv
function y = fir4_rtl_model(x, shift)
    N = length(x); y = zeros(1, N); d = zeros(1, 4);
    for k = 1:N
        d = [x(k) d(1:3)];          % delay line: x[n], x[n-1], x[n-2], x[n-3]
        sum_a  = d(1) + d(4);       % x[n] + x[n-3]
        sum_b  = d(2) + d(3);       % x[n-1] + x[n-2]
        prod_b = sum_b * 3;
        y(k) = floor((sum_a + prod_b) / 2^shift);
    end
end

function print_table(name, x, ye, yr)
    fprintf('\n=== %s ===\n', name);
    fprintf('  n      x    y_exact   y_rtl   error\n');
    for k = 1:length(x)
        fprintf('%3d %6d %10.3f %7d %7.3f\n', k-1, x(k), ye(k), yr(k), ye(k) - yr(k));
    end
end