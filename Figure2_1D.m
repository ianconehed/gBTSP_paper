clearvars -except plat_per_time_set act_per_time_set z_t_corr_set z_t_corr_sort_set p
close all

% rng(9)

%%make for 2d unsupervised

N_input = 200; 
% num_trials = 5;
num_trials = 100;
t_total = 100;
N_in_s = 10;
N_in = N_in_s^2;
N_rec_s = 9;
N_rec = N_rec_s^2;


alpha = 1;
beta = 1;
gamma = 0*.9;
r_factor = 50;

x_t = zeros(N_in,t_total);

W = 0*randn(N_rec,N_in)/10000;
max_act_tracker = zeros(t_total,num_trials);
select_tracker = zeros(t_total,num_trials);

z_t_tracker = zeros(t_total,num_trials);
z_t_trials = zeros(N_rec,t_total,num_trials);



select_thresh = .05*N_rec;

% x_t_traj = randomWalk(100,100,1,num_trials,40);

x_t_traj = zeros(N_in,t_total);

std_inp = 1;
for i = 1:N_in
    x_t_traj(i,:) = circshift(gauss_func(1:t_total,t_total/2,std_inp,1),ceil((t_total/N_in)*i)-t_total/2);
end

x_t_traj(71:100,1:40) = 0;
x_t_traj(1:40,71:100) = 0;

x_t_traj_basic = x_t_traj;

x_t_traj = x_t_traj_basic;

plat_per_time = zeros(1,num_trials);
act_per_time = zeros(1,num_trials);

t_window = 10;

tau_1 = 1.31;
tau_2 = .69;

lambda = .95;
eta = .95;
max_thresh = 8;
track_idx = 7;

% lambda = 1;
% eta = 1;
% max_thresh = 6;





%%
% figure('Position', [200 300 1800 1000]);
figure;
for l = 2:num_trials
    p_t = zeros(N_rec,t_total);
    z_t = zeros(N_rec,t_total);
    del_W = zeros(N_rec,N_in);
    int_window = zeros(N_rec,t_total);
    for t = 1:t_total

        x_t(:,t) = x_t_traj(:,t) + randn(N_in,1)/35;
        x_temp = x_t(:,t);
        z_t(:,t) = tanh(W*x_t(:,t));
        z_t(:,t) = z_t(:,t).*(z_t(:,t)>0);
        z_t_tracker(t,l) = z_t(track_idx,t);

        sum_act= sum(z_t(:,t));
        max_act_tracker(t,l) = sum_act;
        z_t_trials(:,t,l) = z_t(:,t);


        if sum_act<max_thresh && t>10 && t<80 
            match_idx = randi(N_rec);
            if int_window(match_idx,t) == 0 && sum(p_t(match_idx,:)) == 0
                p_t(match_idx,t) = 1;
                int_window(match_idx,(t-t_window + 1):(t + t_window)) = 1;
            end
        end
        [p_loc,p_time] = find(p_t);
        for i = 1:length(p_loc)
            p_idx = p_loc(i);
            p_time_idx = p_time(i);
            if int_window(p_idx,t) == 1
                W_kernel = exp_kernel(t,p_time_idx,tau_1,tau_2)';
                del_W(p_idx,:) = del_W(p_idx,:) + W_kernel*x_t(:,t)';
                % W(p_idx,:) = W(p_idx,:) + del_W(p_idx,:);eta*(W_kernel*x_t(:,t)'- lambda*W(p_idx,:));
            end
        end
        

    end
    for i = 1:length(p_loc)
        p_idx = p_loc(i);
        W(p_idx,:) = W(p_idx,:) + eta*(del_W(p_idx,:) - lambda*W(p_idx,:));
        % W = W.*(W>0);
    end


    % [p_loc,p_time] = find(p_t);
    % for i = 1:length(p_loc)
    %     p_idx = p_loc(i);
    %     p_time_idx = p_time(i);
    %     t_vec=linspace(-t_window + p_time_idx, t_window + p_time_idx,2*t_window+1);
    %     W_kernel = exp_kernel(t_vec,p_time_idx,tau_1,tau_2)';
    %     for t = 1:length(t_vec)
    %         del_W(i,:) = del_W(i,:) + W_kernel(t)*x_t(:,t_vec(t))';
    %     end
    % end
    % del_W = eta*del_W - lambda*W;
    % W = W + del_W;

    plat_per_time(l) = sum(p_t,"all")/t_total;
    act_per_time(l) = sum(z_t,"all")/t_total;

    if l<num_trials+1 || mod(l,10) == 0
        [M,I] = max(z_t,[],2);
        [sorted,s_idx] = sort(I);
        disp(l)
        subplot(2,2,1)
        imagesc(x_t(s_idx,:))
        xlim([11 80])
        xlabel('time')
        ylabel('input neuron index')
        title('input')
        colorbar
        subplot(2,2,2)
        imagesc(p_t)
        xlim([11 80])
        xlabel('time')
        ylabel('unit number')
        title('plasticity events')
        colorbar
        % subplot(2,2,3)
        % imagesc(p_t_no_mask)
        % xlabel('time')
        % ylabel('unit number')
        % title('plasticity events (no mask)')
        % colorbar
        % subplot(2,3,3)
        % imagesc(W_in)
        % xlabel('dim 1')
        % ylabel('dim 2')
        % title('input weights')
        % colorbar
        % subplot(2,2,1)
        % plot(max_act_tracker(:,l),'k-')
        % xlabel('time')
        % ylabel('total activity')
        % title('total activity')
        subplot(2,2,3)
        % plot(select_tracker(:,l),'r-')
        % xlabel('time')
        % ylabel('selectivity')
        % title('selectivity')
        imagesc(z_t_tracker')
        xlim([11 80])
        xlabel('time')
        ylabel('trial number')
        title('single unit activiation over trials')
        colorbar
        subplot(2,2,4)
        imagesc(z_t(s_idx,:))
        xlim([11 80])
        xlabel('time')
        ylabel('unit index sorted')
        title('unit activations')
        colorbar
        drawnow  
    end
end


figure;
plot(movmean(plat_per_time,[2 2]))
hold on
plot(movmean(act_per_time,[2 2]))


%%
z_t_corr = zeros(1,num_trials);
sim_test = reshape(z_t_trials(:,11:80,15),1,[]);
z_t_corr_sort = zeros(1,num_trials);

sim_test_sort = reshape(z_t_trials(:,11:80,15),N_rec,70);
[M,I] = max(sim_test_sort,[],2);
[sorted,s_idx] = sort(I);
sim_test_sort = reshape(sim_test_sort(s_idx,:),1,[]);

for l = 1:num_trials
    sim_temp = reshape(z_t_trials(:,11:80,l),1,[]);
    sim_temp2 = reshape(z_t_trials(:,11:80,l),N_rec,70);
    [M,I] = max(sim_temp2,[],2);
    [sorted,s_idx] = sort(I);
    sim_temp_sort = reshape(sim_temp2(s_idx,:),1,[]);
    z_t_corr(l) = dot(sim_temp,sim_test)/(norm(sim_temp)*norm(sim_test));
    z_t_corr_sort(l) = dot(sim_temp_sort,sim_test_sort)/(norm(sim_temp_sort)*norm(sim_test_sort));
end

figure;
plot(z_t_corr)
hold on
plot(z_t_corr_sort)