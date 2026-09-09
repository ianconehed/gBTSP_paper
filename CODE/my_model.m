function y_pred = my_model(x, W)
    % Compute predictions of the model
    % X: input data
    % theta: parameters of the model
    
    % Compute predictions using current parameters

    % for t = 2:t_total
    %     rec_input = W_rec*h_jt(:,t-1);
    %     ext_input = W_in*x_tonic(:,t);
    %     u_jt(:,t) = fun_t(rec_input + ext_input);
    %     del_hj = (-h_jt(:,t-1) + u_jt(:,t))*(dt/tau_net);
    %     h_jt(:,t) = h_jt(:,t-1) + del_hj;
    %     y_it(t) = W_out*h_jt(:,t);
    % end


    y_pred = W*x;
end
