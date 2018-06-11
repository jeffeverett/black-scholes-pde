function [t_vals,S_vals,surface] = black_scholes_cov_explicit(N,M,Smin,Smax,T,K,volatility,r,d,is_call)

% create empty surface
surface = zeros(1+N,1+M);

% undergo change of variables to tau and x:
% first note that tauMin=0 when t=T
% and tauMax=sigma^2*T/2 when t=0
tauMax = volatility.^2*T/2;
dtau = tauMax/N;
tau_vals = 0:dtau:tauMax;
% next note that xMin = ln(Smax/K)
% and xMax=ln(Smin/K)
% also note that Smin cannot equal 0
% or xMax would not be defined
xMax = log(Smax/K);
xMin = log(Smin/K);
dx = (xMax-xMin)/M;
x_vals = xMin:dx:xMax;

% define values relevant to change of variables
k = r/(volatility.^2/2);
kprime = (r-d)/(volatility.^2/2);
alpha = -0.5*(kprime-1);
beta = -0.25*(kprime-1).^2-k;
g = @(x,tau) exp((0.25*(kprime-1).^2+k)*tau)* ...
    max(exp(0.5*(kprime+1)*x)-exp(0.5*(kprime-1)*x),0);

% return grid transformed back into t and S
t_vals = T-2*tau_vals./volatility.^2;
S_vals = K*exp(x_vals);

% here, s is the familiar s from finite-difference methods for heat eqn
s = dtau/(dx*dx);
fprintf('s is %f (must be <=0.5)\n',s)

% set boundary conditions
if is_call
    surface(:,1) = 0;
    surface(:,end) = g(xMax,tau_vals);
    surface(1,:) = g(x_vals,0);
else
    surface(:,1) = 0;
    surface(:,end) = K;
    surface(1,:) = payoff(S_vals,K,is_call);
end

% compute remaining values
for i=2:N+1   
    for j=2:M
        surface(i,j) = s*surface(i-1,j-1)+(1-2*s)*surface(i-1,j)+s*surface(i-1,j+1);
    end
    
    % enforce free boundary condition
    surface(i,2:M) = max(surface(i,2:M),g(x_vals(2:M),tau_vals(i)));
end

% transform surface values of u back into option price
[mesh_x,mesh_tau] = meshgrid(x_vals,tau_vals);
surface = K*exp(alpha*mesh_x+beta*mesh_tau).*surface;

end