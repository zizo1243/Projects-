clc
clear all
close all
%   STEP 1 — Load the Signal
x_orig = readmatrix("dataset.csv");   % column vector
x_orig = x_orig(:);                   % ensure column vector
N_orig = length(x_orig);
%   STEP 2 — Time-Domain Plot of Original Signal
figure;
plot(x_orig, 'LineWidth', 1.2);
title("Original Signal (Time Domain)");
xlabel("Sample index");
ylabel("Amplitude");
grid on;
%   STEP 3 — PSD using pwelch (Welch Method)
figure;
pwelch(x_orig, [], [], [], 'onesided');
title("Original Signal PSD (Welch Method)");

%% plotting the time and frequency domain by changing k and N added 
k_list = [5 10 15];
Nadd_list = [100 200 300];

for ki = 1:length(k_list)
    %% computing  the autocorrelation Rxx
    k = k_list(ki);
    N = length(x_orig);
    r = zeros(k+1, k+1);
    for i = 1:k+1
        for j = 1:k+1
            lag = abs(i - j);
            r(i,j) = sum( x_orig(1:N-lag) .* x_orig(1+lag:N) ) / N;
        end
    end
    R = r;
    %% computing ryx
  rxy=R(k+1,1:k).' ; 
%% computing h 
Rxx=R(1:k,1:k);
h= flipud(Rxx \ rxy);
%% getting the extrapolated functions 
for ni = 1:length(Nadd_list)
    N_added = Nadd_list(ni);
    x_ext = x_orig;    % start from original signal
    for n = 1:N_added
        past = flipud( x_ext(length(x_ext)-k+1:length(x_ext)) );   % x[n-1],x[n-2],...,x[n-k]
        x_new = h' * past;                     % predicted next sample
        x_ext(length(x_ext)+1,1) = x_new;                 % added to the signal
    end

    %% ---- TIME DOMAIN PLOT ----
    figure;
    plot(x_ext, 'LineWidth',1.2);
    title(sprintf("Extrapolated Signal (Lecture Predictor) k=%d, Nadded=%d", k, N_added));
    xlabel("Sample Index");
    ylabel("Amplitude");
    grid on;
    hold on;
    plot(x_orig, 'LineWidth', 1.2);
    
    %% ---- PSD PLOT ----
    figure;
    pwelch(x_ext, [], [], [], 'onesided');
    hold on;
    pwelch(x_orig, [], [], [], 'onesided');
    legend("Extended","Original");
    title(sprintf("PSD Comparison (Lecture Predictor) k=%d, Nadded=%d", k, N_added));
end
end 