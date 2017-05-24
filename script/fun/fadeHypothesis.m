function h = fadeHypothesis(X,theta,options)
h=[];
if options.FADE_MODEL_TO_USE == options.POLY_FADE_MODEL_LABEL_CONSTANT
    h = X*theta;
elseif options.FADE_MODEL_TO_USE == options.LOG_FADE_MODEL_LABEL_CONSTANT
    h = X(:,1)*theta(3) + 10.^(-(X(:,2)+theta(1))/(theta(2)));
elseif options.FADE_MODEL_TO_USE == options.POLY2_MODEL_LABEL_CONSTANT
    h = X*theta;
%     h=zeros(size(X,1),size(theta,2));
%     for i = 1:size(theta,2)
%         h(:,i) = X(:,1)*theta(3) + 10.^(-(X(:,2)+theta(1))/(theta(2)));
%     end
end