clear all
close all


rng(9)


t_total = 100;
num_trials = 2;
N_l1 = 100;
N_l2 = 80;
N_in = 100;
eta = 1;
lambda = 1;

x_t_traj = zeros(N_in,t_total);

std_inp = 5;
for i = 1:N_in
    x_t_traj(i,:) = circshift(gauss_func(1:t_total,t_total/2,std_inp,1),ceil((t_total/N_in)*i)-t_total/2);
end

x_t = x_t_traj;

W_in = 0*randn(N_l1,N_in)/sqrt(N_in);
W_d = 0*randn(N_l1,N_l2)/sqrt(N_l2);
W_e = 0*.001*randn(N_l2,N_l1)/sqrt(N_l1);


max_thresh = .95;


%%
figure('Position', [200 300 1200 600]);
del_W_e = zeros(N_l2,N_l1);
del_W_d = zeros(N_l1,N_l2);
del_W_e_sanger = zeros(N_l2,N_l1);
p_t = zeros(N_l2,t_total);
u_t = zeros(N_l1,t_total);
s_t = zeros(N_l2,t_total);


%%  fix this time business!! maybe roll out as ff network?
alpha = 0;
for l = 1:num_trials
    p_t = zeros(N_l2,t_total);
    u_t = zeros(N_l1,t_total);
    s_t = zeros(N_l2,t_total);
    for t = 2:t_total
        if l == 1
            input = x_t(:,t-1)-.1;
        elseif l ~= 1 && mod(t,20) == 2
            input = x_t(:,t)-.1;
            disp('condition')
            % alpha = .75;
        else
            input = 0;
        end
        alpha = (2.71 - norm(input))/2.71;
        % alpha = .5;
        u_t(:,t-1) = tanh((1-alpha)*input + alpha*W_d*s_t(:,t-1));
        s_t(:,t) = tanh(W_e*u_t(:,t-1));
        s_t(:,t) = s_t(:,t).*(s_t(:,t)>0);
    
        [max_act, max_idx] = max(s_t(:,t));
    
        if max_act<max_thresh
            match_idx = randi(N_l2);
            p_t(match_idx,t) = 1;
            disp('plateau')
            % s_t()
            W_e(match_idx,:) = W_e(match_idx,:) + eta*(u_t(:,t-1)' - lambda*W_e(match_idx,:));
            W_d = W_e';
            %maybe, since weight changes are at the end of a trial (over
            %times and taus), should temporarily burst (high s(t) for a few
            %tau/timesteps) so we don't keep hitting the plateau condition
    
        end
    
        s_t(:,t) = tanh(W_e*u_t(:,t-1));
        s_t(:,t) = s_t(:,t).*(s_t(:,t)>0);
    
        if t<t_total+1
            [M,I] = max(u_t,[],2);
            [sorted,y_idx] = sort(I);
            disp(t)
            subplot(2,2,1)
            imagesc(u_t(:,1:t_total))
            xlabel('time')
            ylabel('neuron index')
            title('layer 1 (visible)')
            colorbar
            subplot(2,2,2)
            imagesc(s_t(:,1:t_total))
            xlabel('time')
            ylabel('neuron index')
            title('layer 2 (hidden)')
            colorbar
            subplot(2,2,3)
            imagesc(W_e)
            xlabel('neuron index')
            ylabel('neuron index')
            title('W_e')
            colorbar
            subplot(2,2,4)
            imagesc(W_d*W_e)
            xlabel('neuron index')
            ylabel('neuron index')
            title('W_e times W_d')
            drawnow  
        end
    end
end




    %     if sum_act<max_thresh && tau>10 && tau<80 
    %         match_idx = randi(N_rec);
    %         if int_window(match_idx,tau) == 0 && sum(p_t(match_idx,:)) == 0
    %             p_t(match_idx,tau) = 1;
    %             int_window(match_idx,(tau-t_window + 1):(tau + t_window)) = 1;
    %         end
    %     end
    %     [p_loc,p_time] = find(p_t);
    %     for i = 1:length(p_loc)
    %         p_idx = p_loc(i);
    %         p_time_idx = p_time(i);
    %         if int_window(p_idx,tau) == 1
    %             W_kernel = exp_kernel(tau,p_time_idx,tau_1,tau_2)';
    %             del_W(p_idx,:) = del_W(p_idx,:) + W_kernel*x_t(:,tau)';
    %             % W(p_idx,:) = W(p_idx,:) + del_W(p_idx,:);eta*(W_kernel*x_t(:,t)'- lambda*W(p_idx,:));
    %         end
    %     end
    % 
    % 
    % end
    % for i = 1:length(p_loc)
    %     p_idx = p_loc(i);
    %     W(p_idx,:) = W(p_idx,:) + eta*(del_W(p_idx,:) - lambda*W(p_idx,:));
    %     % W = W.*(W>0);
    % end

%%

%prune zero connections

idxs = find(sum(W_e,2));

W_C = (W_d*W_e)*(W_d*W_e)';
[coeff,score,latent,~,explained] = pca(W_C);

figure;
scatter3(score(:,1),score(:,2),score(:,3),'filled')
axis equal
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')