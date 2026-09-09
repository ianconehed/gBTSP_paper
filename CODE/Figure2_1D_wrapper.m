clear all
close all


num_meta_trials = 15;

z_t_corr_set = zeros(num_meta_trials,100);
z_t_corr_sort_set = zeros(num_meta_trials,100);

plat_per_time_set = zeros(num_meta_trials,100);
act_per_time_set = zeros(num_meta_trials,100);


for p = 1:num_meta_trials
    run('Figure2_1D.m')
    z_t_corr_set(p,:) = z_t_corr;
    z_t_corr_sort_set(p,:) = z_t_corr_sort;
    % plat_per_time_set(p,:) = plat_per_time;
    % act_per_time_set(p,:) = act_per_time;
    plat_per_time_set(p,:) = movmean(plat_per_time,[2 2]);
    act_per_time_set(p,:) = movmean(act_per_time,[2 2]);
end


%%
figure;
varplot(z_t_corr_set(:,3:100)','std')
hold on
varplot(z_t_corr_sort_set(:,3:100)','std')
hold off

%%
figure;
varplot(plat_per_time_set(:,1:50)','std')
hold on
varplot(act_per_time_set(:,1:50)','std')
hold off