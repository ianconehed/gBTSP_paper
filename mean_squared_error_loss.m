function loss = mean_squared_error_loss(W, x, y)
    % Calculate the mean squared error loss function
    % theta: parameters of the model
    % X: input data
    % y: output data
    
    % Compute predictions using current parameters
    y_pred = my_model(x, W);
    
    % Calculate mean squared error
    loss = mean((y - y_pred).^2);
end
