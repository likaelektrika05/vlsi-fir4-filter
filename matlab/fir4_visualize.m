% fir4_visualize.m -- 6-figure visualization suite for the [1 3 3 1]/8 FIR
function fir4_visualize()
    b  = [1 3 3 1] / 8;
    Fs = 300e6;
    fprintf('\n=== fir4 Visualization Suite ===\n');
    fprintf('Filter: H(z) = (1 + 3z^{-1} + 3z^{-2} + z^{-3}) / 8\n');
    fprintf('Sample rate: %d MHz\n', Fs/1e6);

    % ---- Figure 1: frequency response ----
    w = linspace(0, pi, 1024);
    H = b * exp(-1j * (0:3)' * w);          % H(e^jw) computed directly
    f = w / (2*pi) * Fs / 1e6;              % MHz
    mag_db = 20*log10(abs(H) + eps);
    idx3 = find(mag_db <= -3, 1, 'first');
    figure('Name', 'Fig 1: Frequency response');
    subplot(2,1,1);
    plot(f, mag_db, 'b', 'LineWidth', 2); hold on; grid on;
    yline(-3, 'r--', '-3 dB');
    xline(f(idx3), 'k:', sprintf('%.1f MHz', f(idx3)));
    ylim([-60 5]); xlabel('Frequency (MHz)'); ylabel('|H| (dB)');
    title('Magnitude Response -- [1,3,3,1]/8 Binomial Low-Pass');
    subplot(2,1,2);
    plot(f, unwrap(angle(H)) * 180/pi, 'b', 'LineWidth', 2); grid on;
    xlabel('Frequency (MHz)'); ylabel('Phase (deg)');
    title('Phase Response (linear phase -- symmetric taps)');

    % ---- Figure 2: pole-zero plot ----
    z = roots(b);
    th = linspace(0, 2*pi, 256);
    figure('Name', 'Fig 2: Pole-zero');
    plot(cos(th), sin(th), 'k:'); hold on; grid on; axis equal;
    plot(real(z), imag(z), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
    plot(0, 0, 'rx', 'MarkerSize', 12, 'LineWidth', 2);
    xlim([-1.5 1.5]); ylim([-1.5 1.5]);
    title('Pole-Zero: triple zero at z = -1 (null at Nyquist), 3 poles at z = 0');

    % ---- Figure 3: impulse response ----
    x_imp = [64 zeros(1,7)];
    y_imp = fir4_rtl(x_imp);
    figure('Name', 'Fig 3: Impulse response');
    stem(0:7, y_imp, 'filled', 'LineWidth', 1.5); grid on;
    xlabel('n'); ylabel('y[n]');
    title('Impulse response for x[0] = 64:  [8 24 24 8]');

    % ---- Figure 4: chirp test ----
    N = 256;
    t = linspace(0, 1, N);
    x_chirp = round(100 * sin(2*pi * (0.5 + 60*t) .* t));
    x_chirp = max(min(x_chirp, 127), -128);
    y_chirp = fir4_rtl(x_chirp);
    figure('Name', 'Fig 4: Chirp');
    plot(0:N-1, x_chirp, 'Color', [0.6 0.6 0.6]); hold on; grid on;
    plot(0:N-1, y_chirp, 'b', 'LineWidth', 1.5);
    xlabel('Sample n'); ylabel('Amplitude'); legend('input x', 'output y');
    title('Chirp: low freqs pass, high freqs attenuated');

    % ---- Figure 5: spectrogram (input vs output) ----
    figure('Name', 'Fig 5: Spectrogram');
    subplot(1,2,1); imagesc(stft_db(x_chirp)); axis xy; colorbar;
    title('Input chirp'); xlabel('Time frame'); ylabel('Frequency bin');
    subplot(1,2,2); imagesc(stft_db(y_chirp)); axis xy; colorbar;
    title('Filtered output'); xlabel('Time frame'); ylabel('Frequency bin');

    % ---- Figure 6: quantization error ----
    y_exact = filter(b, 1, x_chirp);
    err = y_exact - y_chirp;
    figure('Name', 'Fig 6: Quantization error');
    plot(0:N-1, err, 'r.'); grid on;
    xlabel('Sample n'); ylabel('exact - RTL');
    title(sprintf('Quantization error from floor(): max = %.3f LSB', max(abs(err))));

    fprintf('\nAll 6 figures generated.\n');
end

% Hardware-equivalent model (shift right by 3)
function y = fir4_rtl(x)
    N = length(x); y = zeros(1, N); d = zeros(1, 4);
    for k = 1:N
        d = [x(k) d(1:3)];
        y(k) = floor(((d(1) + d(4)) + 3*(d(2) + d(3))) / 8);
    end
end

% Simple short-time FFT magnitude in dB (no toolbox needed)
function S = stft_db(x)
    L = 32; hop = 8;
    win = 0.5 - 0.5*cos(2*pi*(0:L-1)'/(L-1));   % Hann window
    nfr = floor((length(x) - L) / hop) + 1;
    S = zeros(L/2 + 1, nfr);
    for k = 1:nfr
        seg = x((k-1)*hop + (1:L));
        X = fft(seg(:) .* win);
        S(:, k) = 20*log10(abs(X(1:L/2+1)) + 1);
    end
end