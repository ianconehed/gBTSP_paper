function grad = numerical_gradient_function(W, x, y)
    % Calculate the gradient of the loss function
    % numerically with respect to the parameters (theta)
    
    % Define a small step size for numerical differentiation
    epsilon = 1e-6;
    
    % Initialize gradient vector
    grad = zeros(size(W));
    aa = size(W);
    
    % Compute the gradient for each parameter
    for j = 1:aa(2)
        for i = 1:aa(1)
            % Perturb the parameter value by epsilon
            theta_plus = W;
            theta_plus(i,j) = theta_plus(i,j) + epsilon;

            % Calculate loss values for perturbed parameter
            loss_plus = mean_squared_error_loss(theta_plus, x, y);

            % Perturb the parameter value by -epsilon
            theta_minus = W;
            theta_minus(i,j) = theta_minus(i,j) - epsilon;

            % Calculate loss values for perturbed parameter
            loss_minus = mean_squared_error_loss(theta_minus, x, y);

            % Calculate the gradient using central difference approximation
            grad(i,j) = (loss_plus(i) - loss_minus(i)) / (2 * epsilon);
        end
    end
end
