function y = exp_kernel(t,t_plat,tau_1,tau_2)
y = 2*(exp((t-t_plat)/tau_1).*(t<=t_plat) + exp(-(t-t_plat)/tau_2).*(t>t_plat));
end