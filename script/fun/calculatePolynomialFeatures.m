function [X_poly] = calculatePolynomialFeatures(X, p)

noOfExamples = size(X,1);
noOfFeatures = size(X,2);

X_poly = zeros(noOfExamples, noOfFeatures*p);


for i=1:p
    for f = 1:noOfFeatures
        X_poly(:,f+noOfFeatures*(i-1)) = X(:,f).^i;
    end
end


% =========================================================================

end
