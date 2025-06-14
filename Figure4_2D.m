clearvars -except abs_set err_set p
close all
rng(9);

t_total = 100;
dt = 1;
N_input = 100;
N_inter = 10;
N_output = 2;
num_trials = 10;

eta = .6;
alpha = 0*.2;
beta = 0*.002;
lambda = 0*.05;

delta_t_kernel = 10;
delta_t_x = 2.5;

tau_1 = 4*1.31;
tau_2 = 4*.69;

x_jt = eye(N_input,t_total); %input signal in t

% for i = 1:N_input
%     x_jt(i,:) = gauss_func(1:t_total,round(i*(t_total/N_input)),delta_t_x,1)/5;
% end

asym = 0;

W_kernel = exp_kernel(1:t_total,t_total/2,tau_1,tau_2);
% W_kernel = gauss_func(1:t_total,(t_total/2)+asym,delta_t_kernel,1);
W_kernel2 = zeros(1,3*t_total);
W_kernel2((t_total+1):(2*t_total)) = W_kernel;

W_ij = 0*ones(N_inter,N_input)/sqrt(N_input); %input weights
V_ki = randn(N_output,N_inter)/sqrt(N_inter); %input weights
% U_mk = randn(N_output,N_inter2)/sqrt(N_inter2); %input weights

y_targ = zeros(N_output,t_total);
y_targ(1,:) = cos(2*pi*(0:t_total-1)/t_total) + .5*sin(2*2*pi*(0:t_total-1)/t_total)...
    + .25*cos(4*2*pi*(0:t_total-1)/t_total);
y_targ(2,:) = sin(2*pi*(0:t_total-1)/t_total) + .5*sin(2*2*pi*(0:t_total-1)/t_total)...
    + .25*sin(4*2*pi*(0:t_total-1)/t_total);
% y_targ(2,:) = gauss_func(1:t_total,round(t_total/4),10,1);
y_t_trials = zeros(N_output,num_trials,t_total);

P_jt_tracker = zeros(N_inter,num_trials,t_total);
err_list = zeros(1,num_trials);
err_list2 = zeros(1,num_trials);

% x_jt(1,1) = 1;

%%
figure('Position', [100 100 1200 600]);
for l = 1:num_trials
    P_it = zeros(N_inter,t_total); %plateau signal
    W_p = zeros(N_input,t_total);
    del_P = zeros(N_inter,t_total);
    del_W = zeros(N_inter,N_input);
    
    u_it = W_ij*x_jt;
    y_kt = V_ki*u_it;
    % z_mt = U_mk*y_kt;

    
    %%tried to simplify this, but I know this works
    for t = 1:t_total
        for t_prime = 1:t_total
            t_ind = t_prime-t + round(3*t_total/2);
            W_p(:,t) = W_p(:,t) + W_kernel2(t_ind).*x_jt(:,t_prime);
        end
    end
    P_jt = zeros(N_inter,t_total);
    for t = 2:t_total
        x_term = x_jt(:,t)'/W_p(:,t)';
        err_inter = V_ki'*(y_targ(:,t)-y_kt(:,t));
        P_jt(:,t) = eta*err_inter*x_term;
    end

    del_W = P_jt*W_p';

    W_ij = W_ij + eta*(del_W - lambda*W_ij);
    P_jt_tracker(:,l,:) = P_jt;

    y_t_trials(:,l,:) = y_kt;
    err_list(l) = .5*mean((y_targ-y_kt).^2,'all');
    
    disp(l)
    if mod(l,1) == 0
        subplot(2,3,1)
        imagesc(x_jt)
        title('input')
        subplot(2,3,2)
        plot3(y_kt(1,:),y_kt(2,:),1:t_total)
        axis tight, grid on, view(0,90)
        x = y_kt(1,:); y = y_kt(2,:); z = 1:t_total;
        c = 1:numel(1:t_total);      %# colors
        h = surface([x(:), x(:)], [y(:), y(:)], [z(:), z(:)], ...
            [c(:), c(:)], 'EdgeColor','flat', 'FaceColor','none');
        colormap( parula(numel(1:t_total)) )
        colorbar

        hold on
        plot3(y_targ(1,:),y_targ(2,:),1:t_total,'k--')
        hold off
        % plot(y_kt(1,:))
        % hold on
        % plot(y_targ(1,:),'k--')
        % hold off
        title('output and target')
        subplot(2,3,3)
        imagesc(u_it)
        title('u_it')
        subplot(2,3,4)
        loglog(err_list)
        xlabel('trial number')
        ylabel('error')
        title('error')
        subplot(2,3,5) 
        imagesc(reshape(y_t_trials(1,:,:),[num_trials t_total]))
        ylabel('trials')
        xlabel('time')
        title('ouput activity1')
        subplot(2,3,6) 
        imagesc(reshape(P_jt_tracker(1,:,:),[num_trials t_total]))
        ylabel('trials')
        xlabel('time')
        title('P_t')
        % imagesc(reshape(y_t_trials(2,:,:),[num_trials t_total]))
        % ylabel('trials')
        % xlabel('time')
        % title('ouput activity2')
        drawnow  
    end
end



%%
figure;
subplot(2,2,1)
imagesc(reshape(P_jt_tracker(1,:,:),[num_trials t_total]))
ylabel('trials')
xlabel('time')
title('P_t unit 1')
colorbar
clim([-.04 .04])
subplot(2,2,2)
imagesc(reshape(P_jt_tracker(9,:,:),[num_trials t_total]))
ylabel('trials')
xlabel('time')
title('P_t unit 2')
colorbar
clim([-.04 .04])

%%
abs_P = abs(P_jt_tracker);
abs_P = sum(abs_P,1);
abs_P = sum(abs_P,3);
err_list2 = 1-err_list/err_list(1);

figure;
plot(abs_P/abs_P(1))
hold on
plot(err_list2,'r--')


%%
figure;
subplot(2,2,1)
plot3(y_kt(1,:),y_kt(2,:),1:t_total,LineWidth=2)
axis tight, grid off, view(0,90)
ylim([-2 2])
xlim([-2 2])
x = y_kt(1,:); y = y_kt(2,:); z = 1:t_total;
c = 1:numel(1:t_total);      %# colors
h = surface([x(:), x(:)], [y(:), y(:)], [z(:), z(:)], ...
    [c(:), c(:)], 'EdgeColor','flat', 'FaceColor','none');
colormap( parula(numel(1:t_total)) )
colorbar

hold on
plot3(y_targ(1,:),y_targ(2,:),1:t_total,'k--')
hold off

subplot(2,2,3)
loglog(err_list)
xlabel('trial number')
ylabel('error')
title('error')
subplot(2,2,2)
imagesc(reshape(P_jt_tracker(1,:,:),[num_trials t_total]))
ylabel('trials')
xlabel('time')
title('P_t unit 1')
colorbar

 

%%
c = colormap( viridis(numel(1:t_total)) );
figure;
subplot(2,2,1)
for t = 1:t_total-1
    plot(y_kt(1,t:t+1),y_kt(2,t:t+1),'Color',c(t,:),'LineWidth',4)
    hold on
end
% axis tight, grid off, view(0,90)
ylim([-2 2])
xlim([-2 2])

colorbar

hold on
plot(y_targ(1,:),y_targ(2,:),'k--','LineWidth',2)
hold off

subplot(2,2,3)
loglog(err_list)
xlabel('trial number')
ylabel('error')
title('error')
subplot(2,2,2)
imagesc(reshape(P_jt_tracker(1,:,:),[num_trials t_total]))
ylabel('trials')
xlabel('time')
title('P_t unit 1')
colorbar                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     �