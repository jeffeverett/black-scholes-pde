% Written by group.

function out = payoff(S,K,is_call)

if is_call
    out = max(S-K,0);
else
    out = max(K-S,0);
end

end

