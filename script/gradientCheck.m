% importOptions;
% noOfFeatures = 8;
% noOfExamples = 10;
% noOfOutputs = 2;
% epsilon = 0.000001;
% 
% X = 1:noOfExamples*noOfFeatures;
% X = reshape(-X,noOfExamples,noOfFeatures);
% 
% y = 1:noOfExamples*noOfOutputs;
% y = reshape(-y,noOfExamples,noOfOutputs);
% 
% lambda = options.REGULARIZATION_LAMBDA;
% p = options.POLYNOMIAL_FEATURES_DEGREE;
% %p = 1;
% %Xpower = calculatePowerFeatures(X);
% Xpoly = calculatePolynomialFeatures(X, p);
% [Xpoly, model.mu, model.sigma] = featureNormalize(Xpoly);  % Normalize
% Xpoly = [ones(size(X,1),1), Xpoly]; %add ones
% tetha = 1:size(Xpoly,2)*size(y,2);
% tetha = reshape(tetha,size(Xpoly,2),size(y,2));
% [J, formulaGrad] = costFunction(Xpoly,y,tetha,lambda,options);
% 
% modTeatha = tetha;
% noOfTeathas = size(tetha(:),1);
% numericalGrad = zeros(size(formulaGrad));
% for i = 1 : noOfTeathas
%     if(i == 25)
%         a = 0;
%     end
%     modTeatha(i) = tetha(i) + epsilon;
%     [Jplus, ~] = costFunction(Xpoly,y,modTeatha,lambda,options);
%     
%     modTeatha = tetha;
%     modTeatha(i) = tetha(i) - epsilon;
%     [Jminus, ~] = costFunction(Xpoly,y,modTeatha,lambda,options);
%     
%     numericalGrad(i) = (Jplus-Jminus)/(2*epsilon);
%     modTeatha = tetha;
%     if abs(numericalGrad(i)) < abs(formulaGrad(i))*0.99 || abs(numericalGrad(i)) > abs(formulaGrad(i)*1.01)
%         warning('Gradient is not performing well!');
%     end
% end
















importOptions;
noOfFeatures = 8;
noOfExamples = 10;
noOfOutputs = 2;
epsilon = 0.000001;

links.distance = [1;
         sqrt(2);
         1;
         1;
         sqrt(2);
         1];
     
links.id = [1, 2;
            1, 3;
            1, 4;
            2, 3;
            2, 4;
            3, 4];

links.timestamp = 0;

nodesPosition = [0.3, 1; 1.2, 1.1; 1.4, 0.1; 0, 0];

% nodesPosition
% links
%options
[J, formulaGrad] = layoutErrorCost(nodesPosition, links, options);

modNodesPosition = nodesPosition;
noOfParameters = size(nodesPosition,1) * size(nodesPosition,2);
numericalGrad = zeros(size(formulaGrad));
for nodeNo = 1 : size(nodesPosition,1)
    for directionNo = 1 : size(nodesPosition,2)
        modNodesPosition(nodeNo,directionNo) = nodesPosition(nodeNo,directionNo) + epsilon;
        [Jplus, ~] = layoutErrorCost(modNodesPosition, links, options);
        
        modNodesPosition(nodeNo,directionNo) = nodesPosition(nodeNo,directionNo) - epsilon;
        [Jminus, ~] = layoutErrorCost(modNodesPosition, links, options);
        
        numericalGrad(nodeNo,directionNo) = (Jplus-Jminus)/(2*epsilon);

        if abs(numericalGrad(nodeNo,directionNo)) < abs(formulaGrad(nodeNo,directionNo))*0.99 || abs(numericalGrad(nodeNo,directionNo)) > abs(formulaGrad(nodeNo,directionNo)*1.01)
            warning('Gradient is not performing well!');
        end
    end
end

disp(formulaGrad)
disp(numericalGrad)