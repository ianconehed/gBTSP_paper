function y = dfun_t(x)
y = 1./(cosh(10*tanh(x/10)).^2);
% y = 1.*(x>0);
end