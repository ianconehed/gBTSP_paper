clearvars -except z_cos z_cos_sort p
close all

rng(9)

%%make for 2d unsupervised


num_trials = 100;
t_total = 100;
N_in_s = 10;
N_in = N_in_s^2;
N_rec_s = 10;
N_rec = N_rec_s^2;

eta = 1;

alpha1 = 1;
beta = 1;
gamma = 0;
r_factor = 50;
speed = 1;

x_t = zeros(N_in,t_total);

W_in = randn(N_rec,N_in)/10000;
max_act_tracker = zeros(t_total,num_trials);
select_tracker = zeros(t_total,num_trials);

z_t_tracker = zeros(t_total,num_trials);
W_in_trials = zeros(N_rec,N_rec,num_trials);



max_thresh = .7;
select_thresh = .05*N_rec;

pts = linspace(0,N_in_s,N_in_s);
N_p = length(pts);
X = reshape(repmat(pts,1,N_p),N_p,N_p);
Y = reshape(repmat(pts,N_p,1),N_p,N_p);

plat_per_time = zeros(1,num_trials);

%%
% figure('Position', [200 300 1800 1000]);
for l = 2:num_trials
    p_t = zeros(N_rec,t_total);
    p_t_no_mask = zeros(N_rec,t_total);
    z_t = zeros(N_rec,t_total);
    refractory = zeros(N_rec,1);
    x_t_traj = randomWalk(N_in_s,N_in_s,speed,t_total);
    for t = 1:t_total
        two_dee = exp(-(X-x_t_traj(1,t)).^2-(Y-x_t_traj(2,t)).^2);
        x_t(:,t) = reshape(two_dee,[],1) + randn(N_in,1)/50;   
        x_temp = x_t(:,t);
        z_t(:,t) = tanh(W_in*x_t(:,t));
        z_t_tracker(t,l) = z_t(1,t);

        [max_act, max_idx] = max(z_t(:,t));
        max_act_tracker(t,l) = max_act;


        if max_act<max_thresh
            % disp(['plasticity event',int2str(t)])
            match_idx = randi(N_rec);
            p_t_no_mask(match_idx,t) = 1;
            p_t(match_idx,t) = 1;
            W_in(match_idx,:) = W_in(match_idx,:) + eta*(alpha1*x_temp' - beta*W_in(match_idx,:));
        end

        W_in_trials(:,:,l) = W_in;
        
    end
    plat_per_time(l) = sum(p_t,"all");

    if l<num_trials+1 || mod(l,10) == 0
        % [M,I] = max(z_t,[],2);
        % [sorted,s_idx] = sort(I);
        disp(l)
        % subplot(2,3,1)
        % imagesc(x_t)
        % xlabel('time')
        % ylabel('input neuron index')
        % title('input')
        % colorbar
        % subplot(2,3,2)
        % imagesc(p_t)
        % xlabel('time')
        % ylabel('unit number')
        % title('plasticity events')
        % colorbar
        % subplot(2,3,3)
        % imagesc(p_t_no_mask)
        % xlabel('time')
        % ylabel('unit number')
        % title('plasticity events (no mask)')
        % colorbar
        % % subplot(2,3,3)
        % % imagesc(W_in)
        % % xlabel('dim 1')
        % % ylabel('dim 2')
        % % title('input weights')
        % % colorbar
        % subplot(2,3,4)
        % plot(max_act_tracker(:,l),'k-')
        % xlabel('time')
        % ylabel('total activity')
        % title('total activity')
        % subplot(2,3,5)
        % % plot(select_tracker(:,l),'r-')
        % % xlabel('time')
        % % ylabel('selectivity')
        % % title('selectivity')
        % imagesc(z_t_tracker')
        % xlabel('time')
        % ylabel('trial number')
        % title('single unit activiation over trials')
        % colorbar
        % subplot(2,3,6)
        % imagesc(z_t(s_idx,:))
        % xlabel('time')
        % ylabel('unit index sorted')
        % title('unit activations')
        % colorbar
        % drawnow  
    end
end



%%
% W_in_half = W_in;
t_test = 10*N_in_s;
z_map = zeros(N_rec,t_test,t_test);
z_cos_sim_sort = zeros(1,num_trials);
z_cos_sim = zeros(1,num_trials);


z_map_test = zeros(N_rec,t_test,t_test);
for t1 = 1:t_test
    for t2 = 1:t_test
        two_dee = exp(-(X-t1/10).^2-(Y-t2/10).^2);
        x_t = reshape(two_dee,[],1) + 0*randn(N_in,1)/50;
        z_map_test(:,t1,t2) = z_map_test(:,t1,t2) + tanh(reshape(W_in_trials(:,:,100),[N_rec N_rec])*x_t);
    end
end

[M,I] = max(z_map_test,[],[2 3],"linear");
[sorted,s_idx] = sort(I);
z_map_test_sort = z_map_test(s_idx,:,:);
z_map_trials = zeros(t_test,t_test,num_trials);
z_test_unrolled = reshape(z_map_test,1,[]);
z_test_sort_unrolled = reshape(z_map_test_sort,1,[]);

for l1 = 1:num_trials
    z_map = zeros(N_rec,t_test,t_test);
    for t1 = 1:t_test
        for t2 = 1:t_test
            two_dee = exp(-(X-t1/10).^2-(Y-t2/10).^2);
            x_t = reshape(two_dee,[],1);
            z_map(:,t1,t2) = z_map(:,t1,t2) + tanh(reshape(W_in_trials(:,:,l1),[N_rec N_rec])*x_t);
            z_map_trials(t1,t2,l1) = z_map(10,t1,t2) + tanh(reshape(W_in_trials(10,:,l1),[1 N_rec])*x_t);
        end
    end
    z_cov_temp = reshape(sum(z_map,1),[t_test t_test]);

    [M,I] = max(z_map,[],[2 3],"linear");
    [sorted,s_idx] = sort(I);
    z_map_sort = z_map(s_idx,:,:);
    z_map_unrolled = reshape(z_map,1,[]);
    z_map_sort_unrolled = reshape(z_map_sort,1,[]);
    z_cos_sim(l1) = dot(z_map_unrolled,z_test_unrolled)/(norm(z_map_unrolled)*norm(z_test_unrolled));
    z_cos_sim_sort(l1) = dot(z_map_sort_unrolled,z_test_sort_unrolled)/(norm(z_map_sort_unrolled)*norm(z_test_sort_unrolled));
end


z_map_sum = reshape(sum(z_map,1),[100 100]);
figure;imagesc(z_map_sum/max(z_map_sum,[],'all'))
colormap(viridis)


figure;
pts = linspace(1,t_test,t_test);
xslice = 1:1:t_test;   
yslice = 1:1:t_test;
zslice = 1:1:t_test;
h = slice(pts,pts,pts,(z_map_trials.*(z_map_trials>.15)),xslice,yslice,zslice);
set(h,'EdgeColor','none',...
    'FaceColor','interp',...
    'FaceAlpha','interp');
alpha('color');
% xlabel('x position (cm)')
% ylabel('y position (cm)')
% zlabel('Trial #')
zlim([1 50])
% title('Sinlge unit evolution')
axis xy
view(45,45)
grid on
% colorbar



% figure;
% % imagesc(reshape(sum(z_map,1),[t_test t_test]))
% % clim([0 max(sum(z_map,1),[],"all")])
% plot(z_cos_sim)
% hold on
% plot(z_cos_sim_sort)
% hold off

% figure;
% plot(movmean(plat_per_time,[5 5]))