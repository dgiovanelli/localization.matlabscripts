function [X_norm, mu, sigma] = featureNormalize(X,model)
%FEATURENORMALIZE Normalizes the features in X
%   FEATURENORMALIZE(X) returns a normalized version of X where
%   the mean value of each feature is 0 and the standard deviation
%   is 1. This is often a good preprocessing step to do when
%   working with learning algorithms.
noOfFeatures = size(X,2);
X_norm = zeros(size(X));
if exist('model','var') %if the model is provided the features are scaled based on model mean and std
    mu = model.mu;
    sigma = model.sigma;
    for f=1:noOfFeatures
        X_norm(:,f) = bsxfun(@minus, X(:,f), mu(f));
        
        if sigma(f) ~= 0
            X_norm(:,f) = bsxfun(@rdivide, X_norm(:,f), sigma(f));
        else
            X_norm(:,f) = X_norm(:,f);
        end
    end
else %if the model is not provided the features are scaled based on their mean and std
    mu = zeros(noOfFeatures,1);
    sigma = zeros(noOfFeatures,1);
    for f=1:noOfFeatures
        mu(f) = mean(X(:,f));
        X_norm(:,f) = bsxfun(@minus, X(:,f), mu(f));
        
        sigma(f) = std(X_norm(:,f));
        if sigma(f) ~= 0
            X_norm(:,f) = bsxfun(@rdivide, X_norm(:,f), sigma(f));
        else
            X_norm(:,f) = X_norm(:,f);
        end
    end
end
% ============================================================

end
