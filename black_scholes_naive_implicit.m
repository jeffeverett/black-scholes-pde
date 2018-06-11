function [t_vals,S_vals,surf] = black_scholes_naive_implicit(N,M,Smin,Smax,T,K,volatility,r,d,is_call)

% create empty surface
surf = zeros(1+N,1+M);

% determine differentials
dt = T/N;
dS = (Smax-Smin)/M;

% create grid mesh
t_vals = 0:dt:T;
S_vals = Smin:dS:Smax;

% set boundary conditions
if is_call
    surf(:,1) = 0;
    surf(:,end) = Smax-K;
    surf(end,:) = payoff(S_vals,K,is_call);
else
    surf(:,1) = K;
    surf(:,end) = 0;
    surf(end,:) = payoff(S_vals,K,is_call);
end

% compute remaining values
a = @(j) 0.5*(r-d)*j*dt-0.5*volatility.^2*j.^2*dt;
b = @(j) 1+volatility.^2*j.^2*dt+r*dt;
c = @(j) -0.5*(r-d)*j*dt-0.5*volatility.^2*j.^2*dt;
for i=N:-1:1   
    A = diag(a(2:M-1),-1)+diag(b(2:M))+diag(c(1:M-2),1);
    v = surf(i+1,2:M)';
    v(1) = v(1) - a(1)*surf(i,1);
    v(end) = v(end) - c(M+1)*surf(i,M+1);
    
    surf(i,2:M) = A\v;
    
    % enforce free boundary condition
    surf(i,2:M) = max(surf(i,2:M),payoff(S_vals(2:M),K,is_call));
end

end