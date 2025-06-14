clear all
close all
rng(9);

t_total = 100;
dt = 1;
N_input = 100; 
N_output = 1;
num_trials = 10;

eta = .15;
alpha = 0*.2;
beta = 0*.002;
lambda = .05;

delta_t_kernel = 10;
delta_t_x = 2.5;

tau_1 = 4*1.31;
tau_2 = 4*.69;

x_jt = eye(N_input,t_total); %input signal in t

for i = 1:N_input
    x_jt(i,:) = gauss_func(1:t_total,round(i*(t_total/N_input)),delta_t_x,1)/5;
end

asym = 0;

W_kernel = exp_kernel(1:t_total,t_total/2,tau_1,tau_2);
% W_kernel = gauss_func(1:t_total,(t_total/2)+asym,delta_t_kernel,1);
W_kernel2 = zeros(1,3*t_total);
W_kernel2((t_total+1):(2*t_total)) = W_kernel;

W_j = 0*ones(N_output,N_input)/10; %input weights

y_targ = zeros(N_output,t_total);
y_targ(1,:) = gauss_func(1:t_total,round(t_total/2),5,1);
% y_targ(2,:) = gauss_func(1:t_total,round(t_total/4),10,1);
y_t_trials = zeros(N_output,num_trials,t_total);

P_jt_tracker = zeros(N_output,num_trials,t_total);

err_list = zeros(1,num_trials);
%%
figure('Position', [100 100 1200 600]);
for l = 1:num_trials
    P_jt = zeros(N_output,t_total); %plateau signal
    W_p = zeros(N_input,N_output,t_total);
    W_p1 = zeros(N_input,N_output,t_total);
    W_kernel2_reshape = zeros(N_output,t_total);
    del_P = zeros(N_output,t_total);
    del_W = zeros(N_output,N_input);
    
    y_it = W_j*x_jt;

    
    %%tried to simplify this, but I know this works
    for t = 1:t_total
        for t_prime = 1:t_total
            t_ind = t_prime-t + round(3*t_total/2);
            W_p(:,:,t) = W_p(:,:,t) + W_kernel2(t_ind).*x_jt(:,t_prime);
        end
    end


    for i = 1:N_output
        W_p_temp = reshape(W_p(:,i,:),N_input,t_total);
        del_P(i,:) = (y_targ(i,:)-y_it(i,:)).*diag(W_p_temp'*x_jt)';
        P_jt(i,:) = eta*del_P(i,:);
        del_W(i,:) = P_jt(i,:)*W_p_temp';
    end


    W_j = W_j + eta*(del_W - lambda*W_j);
    P_jt_tracker(:,l,:) = P_jt;

    y_t_trials(:,l,:) = y_it;
    err_list(l) = .5*mean((y_targ-y_it).^2,'all');
    
    disp(l)
    if mod(l,1) == 0
        subplot(2,3,1)
        imagesc(x_jt)
        title('input')
        subplot(2,3,2)
        plot(y_it(1,:))
        hold on
        plot(y_targ(1,:),'k--')
        hold off
        title('output and target')
        subplot(2,3,3)
        plot(W_j(1,:))
        title('W_{out}')
        subplot(2,3,4)
        plot(W_kernel,'k-')
        ylabel('delta W')
        xlabel('time relative to plateau')
        title('W_{kernel}')
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
        drawnow  
    end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      �