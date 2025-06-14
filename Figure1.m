clear all
close all
rng(9);

t_total = 200;
N_input = 200; 

lambda = 1;

delta_t_kernel = 1.5;
delta_t_x = 15;

x_jt = eye(N_input,t_total); %input signal in t

for i = 1:N_input
    x_jt(i,:) = gauss_func(1:t_total,round(i*(t_total/N_input)),delta_t_x,1)/45;
end

t_window = 5;
min_w = 0;
max_w = 1.5;
t_vec=linspace(-t_window, t_window,200);
W_vec=linspace(min_w,max_w,200);
V_vec = W_vec*10;

asym = 0;

t_plat = 0;

tau_1 = 1.31;
tau_2 = .69;
%%
figure('Position', [100 100 1200 600]);

del_W = zeros(1,length(W_vec));
y = zeros(length(t_vec),length(W_vec));
W_kernel = exp_kernel(t_vec,t_plat,tau_1,tau_2)';

for W_ind = 1:length(W_vec)
    W = W_vec(W_ind);
    full = 0;
    for j = 1:N_input
        temp = conv(fliplr(W_kernel'),x_jt(j,:),'full');
        del_W(j) = temp(length(t_vec));
        full = full + temp;
    end
    del_W = del_W - lambda*W;
    y(:,W_ind) = del_W*x_jt';
end



subplot(1,2,1)
plot(t_vec, 1 + W_kernel)
xlabel('Time from plateau (seconds)','FontSize',16)
ylabel('Change relative to baseline','FontSize',16)
title('W_{kernel}')
ylim([1 3.5])
subplot(1,2,2)
imagesc(t_vec,V_vec,10*y')
cmap_c = customcolormap([0 0.5 1], [0.9 0.1 0.1; ...
    1 1 1; ...
    0.2 0.2 0.7]);
xlabel('Time from plateau (seconds)','FontSize',16)
ylabel('Initial V_{m} ramp (mV)','FontSize',16)
ylim([0 13])
colormap(cmap_c)
clim([-15 15])
cb = colorbar(); 
ylabel(cb,'delta V_{m} (mV)','FontSize',16,'Rotation',270)
set(gca,'YDir','normal')
title('delta W')
    
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       �