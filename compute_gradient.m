function [grad, loss] = compute_gradient(W,x,y)
    % Calculate the gradient of the loss function
    % with respect to the parameters (theta)
    
    % Compute loss function
    loss = mean_squared_error_loss(W,x,y);
    
    % Calculate gradient using numerical or analytical methods
    grad =numerical_gradient_function(W, x, y);
end
