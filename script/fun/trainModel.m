function model = trainModel(files,options)
%This solution doesn't consider nodes, it only consider propagation, this means that every rssi sample is taken as a different example,
%then the rssi (and angles) of a link cannot impact on other links.
%Next step could be to treat every link rssi and angles as a single feature, but it is still not clear which should be the output of such model
%(it could be the lenght (in meters) of the first link).
modelTypeStr = options.INPUT_DATA_TYPE;

if strcmp(modelTypeStr,options.ONLY_RSSI_DATA)
    noOfFiles = size(files,1);
    X = [];
    y = [];
    for fileNo = 1:noOfFiles
        noOfLinks = size(files{fileNo}.features.ID1,1);
        noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
        trainingSetLogicalIdx = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks) == 1;
        distance = reshape(cell2mat(files{fileNo}.features.Y.distance),noOfTimeSamples,noOfLinks);
        rssi = reshape(cell2mat(files{fileNo}.features.X.rssi),noOfTimeSamples,noOfLinks);
        X = [X ; rssi(trainingSetLogicalIdx)];
        y = [y ; distance(trainingSetLogicalIdx)];
    end
    nans = isnan(X);
    X = X(~nans);
    y = y(~nans);
    fprintf('%d samples discarded in training because they are NaN.\n',sum(nans));
    
    if options.FADE_MODEL_TO_USE == options.POLY_FADE_MODEL_LABEL_CONSTANT
        lambda = options.REGULARIZATION_LAMBDA;
        p = options.POLYNOMIAL_FEATURES_DEGREE;
        %Xpower = calculatePowerFeatures(X);
        Xpoly = calculatePolynomialFeatures(X, p);
        [Xpoly, model.mu, model.sigma] = featureNormalize(Xpoly);  % Normalize
        Xpoly = [ones(size(X,1),1), Xpoly]; %add ones
        opt = optimset('GradObj', 'on', 'MaxIter', 1000,'MaxFunEvals',1000);
        tetha0 = ones(size(Xpoly,2),1);
    elseif options.FADE_MODEL_TO_USE == options.LOG_FADE_MODEL_LABEL_CONSTANT
        lambda = 0;
        p = 1;
        Xpoly = X; %no polynomial feature into log model!
        [Xpoly, model.mu, model.sigma] = featureNormalize(Xpoly);  % Normalize
        Xpoly = [ones(size(X,1),1), Xpoly]; %add ones
        opt = optimset('GradObj', 'off', 'MaxIter', 1000,'MaxFunEvals',1000);
        tetha0 = ones(size(Xpoly,2)+1,1);
    else
        error('choose one of the two types of model with options.FADE_MODEL_TO_USE');
    end
    model.tetha = fminunc(@(t)(costFunction(Xpoly, y, t, lambda, options)), tetha0,opt);
    model.p = p;
    model.inputDataType = modelTypeStr;
    model.fadeModelType = options.FADE_MODEL_TO_USE;
elseif strcmp(modelTypeStr,options.RSSI_AND_ORIENTATION_DATA)

    p = options.POLYNOMIAL_FEATURES_DEGREE;
    noOfFiles = size(files,1);
    X = [];
    y = [];
    for fileNo = 1:noOfFiles
        noOfLinks = size(files{fileNo}.features.ID1,1);
        noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
        trainingSetLogicalIdx = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks) == 1;
        distance = reshape(cell2mat(files{fileNo}.features.Y.distance),noOfTimeSamples,noOfLinks);
        rssi = reshape(cell2mat(files{fileNo}.features.X.rssi),noOfTimeSamples,noOfLinks);
        node1Orientation = reshape(cell2mat(files{fileNo}.features.X.node1Orientation),noOfTimeSamples,noOfLinks);
        node2Orientation = reshape(cell2mat(files{fileNo}.features.X.node2Orientation),noOfTimeSamples,noOfLinks);
        %         node1AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node1AngleOfLink),noOfTimeSamples,noOfLinks);
        %         node2AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node2AngleOfLink),noOfTimeSamples,noOfLinks);
        %         X = [X ; rssi(trainingSetLogicalIdx) , node1Orientation(trainingSetLogicalIdx), node2Orientation(trainingSetLogicalIdx), node1AngleOfLink(trainingSetLogicalIdx), node2AngleOfLink(trainingSetLogicalIdx)];
        X = [X ; rssi(trainingSetLogicalIdx) , node1Orientation(trainingSetLogicalIdx), node2Orientation(trainingSetLogicalIdx)];
        y = [y ; distance(trainingSetLogicalIdx)];
    end
    nans = isnan(X);
    X = X(~((nans(:,1) | nans(:,2) |  nans(:,3))),:);
    y = y(~(nans(:,1) | nans(:,2) |  nans(:,3)));
    fprintf('%d samples discarded in training because they are NaN.\n',sum(sum(nans)));
    
    if options.FADE_MODEL_TO_USE == options.POLY_FADE_MODEL_LABEL_CONSTANT
        lambda = options.REGULARIZATION_LAMBDA;
        p = options.POLYNOMIAL_FEATURES_DEGREE;
        %Xpower = calculatePowerFeatures(X);
        Xpoly = calculatePolynomialFeatures(X, p);
        [Xpoly, model.mu, model.sigma] = featureNormalize(Xpoly);  % Normalize
        Xpoly = [ones(size(X,1),1), Xpoly]; %add ones
        opt = optimset('GradObj', 'on', 'MaxIter', 1000,'MaxFunEvals',1000);
        tetha0 = ones(size(Xpoly,2),1);
    elseif options.FADE_MODEL_TO_USE == options.LOG_FADE_MODEL_LABEL_CONSTANT
        lambda = 0;
        p = 1;
        Xpoly = X; %no polynomial feature into log model!
        [Xpoly, model.mu, model.sigma] = featureNormalize(Xpoly);  % Normalize
        Xpoly = [ones(size(X,1),1), Xpoly]; %add ones
        opt = optimset('GradObj', 'off', 'MaxIter', 1000,'MaxFunEvals',1000);
        tetha0 = ones(size(Xpoly,2)+1,1);
    else
        error('choose one of the two types of model with options.FADE_MODEL_TO_USE');
    end
    
    model.tetha = fminunc(@(t)(costFunction(Xpoly, y, t, lambda,options)), tetha0,opt);
    model.p = p;
    model.inputDataType = modelTypeStr;
    model.fadeModelType = options.FADE_MODEL_TO_USE;
else
    error('modelTypeStr must be onlyRssi or rssiAndOrientation!');
end