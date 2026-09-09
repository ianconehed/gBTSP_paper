clear all
close all


num_meta_trials = 15;

abs_set = zeros(num_meta_trials,10);
err_set = zeros(num_meta_trials,10);


for p = 1:num_meta_trials
    disp(p)
    run('Figure4_2D.m')
    abs_set(p,:) = abs_P/abs_P(1);
    err_set(p,:) = err_list2;
end


%%
figure;
varplot(abs_set','std')
hold on
varplot(err_set','std')
hold off