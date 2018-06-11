%% Definite initial constants
N = 4000;
M = 1000;
Smin = 0.4; % must be greater than 0 to ensure ln(Smin/K) is defined
Smax = 1000;
T = 1;
K = 10;
volatility = 0.4;
r = 0.02;
is_call = 1;
d = 0;

%% Generate surface
[t_vals,S_vals,surface] = black_scholes_cov_explicit(N,M,Smin,Smax,T,K,volatility,r,d,is_call);

S_check = linspace(0,1.5*K,20);
t_check = linspace(0,T,20);

surf_check = zeros(size(S_check,2),size(t_check,2));
for i=1:size(t_check,2)
    for j=1:size(S_check,2)
        surf_check(i,j) = interp2(S_vals,t_vals,surface,S_check(j),t_check(i));
    end
end

%% Plot surface
surf(S_checks,fliplr(t_checks),surf_check)
xlabel('Stock Price')
ylabel('Time Until Maturity')
title('Example Surface')

%% Interpolate single point and display it
S_check = 30;
t_check = 0.25;
point = interp2(S_vals,t_vals,surface,S_check,t_check);
fprintf('At S=%f and t=%f, dividend price is %f', S_check, t_check, point);