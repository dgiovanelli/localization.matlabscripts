function [X_power] = calculatePowerFeatures(X)

noOfExamples = size(X,1);
noOfFeatures = size(X,2);

X_power = zeros(noOfExamples, noOfFeatures*2);
X_power(:,noOfFeatures) = X;


for f = 1:noOfFeatures
    X_power(:,f+noOfFeatures) = 10.^(-X(:,f));
end



% =========================================================================

end
