% Define initial constants
N = 4000;
M = 1000;
Smin = 0.4; % must be greater than 0 to ensure ln(Smin/K) is defined
Smax = 1000;
T = 1;
K = 10;
volatility = 0.4;
r = 0.02;
is_call = 1;
S_check = linspace(0,15,20);
t_check = linspace(0,T,20);

%% American options with d=0.
d = 0;
[t_vals,S_vals,surface] = black_scholes_cov_explicit(N,M,Smin,Smax,T,K,volatility,r,d,is_call);


% Check results with d=0 for American calls.
% Note: for many parameter choices, the "checking" code is actually slower
% than the solution.
european = zeros(size(S_check,2),size(t_check,2));
american = zeros(size(S_check,2),size(t_check,2));
for i=1:size(t_check,2)
    for j=1:size(S_check,2)
        [european(i,j),~] = blsprice(S_check(j),K,r,T-t_check(i),volatility);
        american(i,j) = interp2(S_vals,t_vals,surface,S_check(j),t_check(i));
    end
end
differences = european-american;


%% Plot differences
surf(S_check,fliplr(t_check),abs(differences))
xlabel('Stock Price')
ylabel('Time Until Maturity')
title('Differences With blsprice')


%% American options with d!= 0
d = 0.08;
[t_vals,S_vals,surface] = black_scholes_cov_explicit(N,M,Smin,Smax,T,K,volatility,r,d,is_call);

% Check reuslts with d!=0 for American calls.
% Note: for many parameter choices, the "checking" code is actually slower
% than the solution.
american_bin = zeros(size(S_check,2),size(t_check,2));
american_fdm = zeros(size(S_check,2),size(t_check,2));
for i=1:size(t_check,2)
    for j=1:size(S_check,2)
        % Note: for simplicity, the usage of the generated binomial trees
        % is done inefficiently.
        
        % binprice fails at T=0
        % also fails for large values of Smax
        if T-t_check(i) ~= 0
            [~,option] = binprice(S_check(j),K,r,T-t_check(i),0.001,volatility,is_call,d);
            american_bin(i,j) = option(1,1);
        else
            american_bin(i,j) = payoff(S_check(j),K,is_call);
        end
        american_fdm(i,j) = interp2(S_vals,t_vals,surface,S_check(j),t_check(i));
    end
end
differences = american_bin-american_fdm;

%% Plot differences
surf(S_check,fliplr(t_check),abs(differences))
xlabel('Stock Price')
ylabel('Time Until Maturity')
title('Differences With binprice (no free boundary check)')

%% Use with real-world data
Smax = 10000;
r = 0.0186;
d = 0.0291;
volatility = 0.1325;
K = 140;
T = 135/365;

[t_vals,S_vals,surface] = black_scholes_cov_explicit(N,M,Smin,Smax,T,K,volatility,r,d,is_call);

S_inspect = 144.16;
value = interp2(S_vals,t_vals,surface,S_inspect,0);
fprintf('Calculated option price: %f\n', value);

%% Plot entire surface (debugging)
surf(S_vals,fliplr(t_vals),surface)
xlabel('Stock Price')
ylabel('Time Until Maturity')
title('Generated Surface')