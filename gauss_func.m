function y = gauss_func(x,center,std,amp)
y = amp*exp((-(x-center).^2)/(2*std^2));
end