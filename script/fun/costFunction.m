function [J, grad] = costFunction(X, y, theta, lambda,options)
%function J = costFunction(X, y, theta, lambda, options)
%size(X) = [ noOfParams(noOfFeatures),noOfExamples ]
%size(y) = [ noOfExamples, 1 ]
%size(theta) = [noOFParams, 1]
%size(lambda) = [1, 1]

m = length(y); % number of training examples CHECK

J = 0;



%calculating hypoteses
h = fadeHypothesis(X,theta,options);

%calculating terms for cost function
squaredDiffSum = (h - y)'*(h - y);
regularizationTerm = theta(2:end)' * theta(2:end);
%calculating the cost function with regularization
J(:) = 1/(2*m) *( squaredDiffSum + lambda * regularizationTerm );

if options.FADE_MODEL_TO_USE == options.POLY_FADE_MODEL_LABEL_CONSTANT
    
    grad = zeros(size(theta));
    %calculating gradients
    grad(:) = 1/m * ( (h - y)' * X);
    %including regularization into gradients
    grad(2:end,1) = grad(2:end,1) + lambda/m*theta(2:end,1);
    
    grad = grad(:);
elseif options.FADE_MODEL_TO_USE == options.LOG_FADE_MODEL_LABEL_CONSTANT
    grad = [];
end