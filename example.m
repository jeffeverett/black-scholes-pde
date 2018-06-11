%% Definite initial constants
N = 1000;
M = 250;
Smin = 0.4; % must be greater than 0 to ensure ln(Smin/K) is defined
Smax = 1000;
T = 1;
K = 10;
volatility = 0.4;
r = 0.02;
is_call = 1;
d = 0.04;

%% Generate and plot surface
[t_vals,S_vals,surface] = black_scholes_cov_explicit(N,M,Smin,Smax,T,K,volatility,r,d,is_call);

S_checks = linspace(0,1.5*K);
t_checks = linspace(0,1);

surf_check = zeros(size(t_checks,2),size(S_checks,2));
for i=1:size(t_checks,2)
    for j=i:size(S_checks,2)
        surf_check(i,j) = interp2(S_vals,t_vals,surface,S_checks(j),t_checks(i));
    end
end

surf(S_checks,fliplr(t_checks),surf_check)
xlabel('Stock Price')
ylabel('Time Until Maturity')
title('Generated Surface')

%% Interpolate single point and display it
S_check = 30;
t_check = 0.25;
point = interp2(S_vals,t_vals,surface,S_check,t_check);
fprintf('Interpolated point has coordinates (%f, %f)', point(1), point(2));