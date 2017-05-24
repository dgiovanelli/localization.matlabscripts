function model = trainModel(files,options)
%This solution doesn't consider nodes, it only consider propagation, this means that every rssi sample is taken as a different example,
%then the rssi (and angles) of a link cannot impact on other links.
%Next step could be to treat every link rssi and angles as a single feature, but it is still not clear which should be the output of such model
%(it could be the lenght (in meters) of the first link).
modelTypeStr = options.INPUT_DATA_TYPE;

if options.FADE_MODEL_TO_USE == options.POLY_FADE_MODEL_LABEL_CONSTANT || options.FADE_MODEL_TO_USE == options.LOG_FADE_MODEL_LABEL_CONSTANT
    if strcmp(modelTypeStr,options.ONLY_RSSI_DATA)
        X = [];
        y = [];
        noOfFiles = size(files,1);
        for fileNo = 1:noOfFiles
            noOfLinks = size(files{fileNo}.features.ID1,1);
            noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
            trainingSetLogicalIdx = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks) == options.TRAIN_SET_LABEL_CONSTANT;
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
            trainingSetLogicalIdx = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks) == options.TRAIN_SET_LABEL_CONSTANT;
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
    elseif strcmp(modelTypeStr,options.RSSI_AND_ORIENTATION_DATA)
        
        p = options.POLYNOMIAL_FEATURES_DEGREE;
        noOfFiles = size(files,1);
        X = [];
        y = [];
        for fileNo = 1:noOfFiles
            noOfLinks = size(files{fileNo}.features.ID1,1);
            noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
            trainingSetLogicalIdx = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks) == options.TRAIN_SET_LABEL_CONSTANT;
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
elseif options.FADE_MODEL_TO_USE == options.POLY2_MODEL_LABEL_CONSTANT
    p = options.POLYNOMIAL_FEATURES_DEGREE;
    noOfFiles = size(files,1);
    X = [];
    y = [];
    
    for fileNo = 1:noOfFiles
        noOfLinks = size(files{fileNo}.features.ID1,1);
        noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
        nodeIdUnderFocus = 33;
        %this reorganizes the links order to be always the same
        newLinkIdx = 1;
        newFeatures = files{fileNo}.features;
        %for linkIdx = 1:noOfLinks
        availableIds = unique([cell2mat(files{fileNo}.features.ID1) ; cell2mat(files{fileNo}.features.ID2)]);
        noOfNodes = size(availableIds,1);
        startingLinkIdxs = find(nodeIdUnderFocus == availableIds);
        for node1Idx = 1: noOfNodes-1
            for node2Idx = node1Idx+1: noOfNodes
                node1ActIdx = mod(node1Idx+startingLinkIdxs-2,noOfNodes)+1;
                node2ActIdx = mod(node2Idx+startingLinkIdxs-2,noOfNodes)+1;
                ID1Act = availableIds(node1ActIdx);
                ID2Act = availableIds(node2ActIdx);
                
                actLinkIdx = find( (cell2mat(files{fileNo}.features.ID1) == ID1Act & cell2mat(files{fileNo}.features.ID2) == ID2Act) | (cell2mat(files{fileNo}.features.ID1) == ID2Act & cell2mat(files{fileNo}.features.ID2) == ID1Act ));
                
                newFeatures.ID1{newLinkIdx} = files{fileNo}.features.ID1{actLinkIdx};
                newFeatures.ID2{newLinkIdx} = files{fileNo}.features.ID2{actLinkIdx};
                newFeatures.set{newLinkIdx} = files{fileNo}.features.set{actLinkIdx};
                newFeatures.X.rssi{newLinkIdx} = files{fileNo}.features.X.rssi{actLinkIdx};
                newFeatures.X.node1Orientation{newLinkIdx} = files{fileNo}.features.X.node1Orientation{actLinkIdx};
                newFeatures.X.node2Orientation{newLinkIdx} = files{fileNo}.features.X.node2Orientation{actLinkIdx};
                newFeatures.X.rssiStd{newLinkIdx} = files{fileNo}.features.X.rssiStd{actLinkIdx};
                newFeatures.X.rssiMean{newLinkIdx} = files{fileNo}.features.X.rssiMean{actLinkIdx};
                newFeatures.Y.distance{newLinkIdx} = files{fileNo}.features.Y.distance{actLinkIdx};
                newFeatures.Y.node1AngleOfLink{newLinkIdx} = files{fileNo}.features.Y.node1AngleOfLink{actLinkIdx};
                newFeatures.Y.node2AngleOfLink{newLinkIdx} = files{fileNo}.features.Y.node2AngleOfLink{actLinkIdx};
                
                newLinkIdx = newLinkIdx+1;
            end
        end
        %end
        
        trainingSetLogicalIdx = reshape(cell2mat(newFeatures.set),noOfTimeSamples,noOfLinks) == options.TRAIN_SET_LABEL_CONSTANT;
        distance = reshape(cell2mat(newFeatures.Y.distance),noOfTimeSamples,noOfLinks);
        rssi = reshape(cell2mat(newFeatures.X.rssi),noOfTimeSamples,noOfLinks);
        node1Orientation = reshape(cell2mat(newFeatures.X.node1Orientation),noOfTimeSamples,noOfLinks);
        node2Orientation = reshape(cell2mat(newFeatures.X.node2Orientation),noOfTimeSamples,noOfLinks);
        node1AngleOfLink = reshape(cell2mat(newFeatures.Y.node1AngleOfLink),noOfTimeSamples,noOfLinks);
        node2AngleOfLink = reshape(cell2mat(newFeatures.Y.node2AngleOfLink),noOfTimeSamples,noOfLinks);
        
        validLinksLogicalIdxX = ones(1,size(newFeatures.ID1,1));%(cell2mat(newFeatures.ID1) == nodeIdUnderFocus | cell2mat(newFeatures.ID2) == nodeIdUnderFocus)';% ones(1,size(newFeatures.ID1,1));
        trainingSetLogicalIdxSelectedLinksX = trainingSetLogicalIdx(:,find(validLinksLogicalIdxX));
        rssiSelectedLinks = rssi(:,find(validLinksLogicalIdxX));
        node1OrientationSelectedLinks = node1Orientation(:,find(validLinksLogicalIdxX));
        node2OrientationSelectedLinks = node2Orientation(:,find(validLinksLogicalIdxX));
        node1AngleOfLinkSelectedLinks = node1AngleOfLink(:,find(validLinksLogicalIdxX));
        node2AngleOfLinkSelectedLinks = node2AngleOfLink(:,find(validLinksLogicalIdxX));
        validLinksLogicalIdxY = (cell2mat(newFeatures.ID1) == nodeIdUnderFocus | cell2mat(newFeatures.ID2) == nodeIdUnderFocus)';% ones(1,size(newFeatures.ID1,1));
        trainingSetLogicalIdxSelectedLinksY = trainingSetLogicalIdx(:,find(validLinksLogicalIdxY));
        distanceSelectedLinks = distance(:,find(validLinksLogicalIdxY));
        
        temp = rssiSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
        rssiFeatures = reshape(temp,size(temp,1)/size(rssiSelectedLinks,2),size(rssiSelectedLinks,2));
        temp = distanceSelectedLinks(trainingSetLogicalIdxSelectedLinksY);
        distanceFeatures = reshape(temp,size(temp,1)/size(distanceSelectedLinks,2),size(distanceSelectedLinks,2));
        temp = node1OrientationSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
        node1OrientationFeatures = reshape(temp,size(temp,1)/size(node1OrientationSelectedLinks,2),size(node1OrientationSelectedLinks,2));
        temp = node2OrientationSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
        node2OrientationFeatures = reshape(temp,size(temp,1)/size(node2OrientationSelectedLinks,2),size(node2OrientationSelectedLinks,2));
        temp = node1AngleOfLinkSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
        node1AngleOfLinkFeatures = reshape(temp,size(temp,1)/size(node1AngleOfLinkSelectedLinks,2),size(node1AngleOfLinkSelectedLinks,2));
        temp = node2AngleOfLinkSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
        node2AngleOfLinkFeatures = reshape(temp,size(temp,1)/size(node2AngleOfLinkSelectedLinks,2),size(node2AngleOfLinkSelectedLinks,2));
        
        %        X = [X ; rssiFetures,node1OrientationFeatures,node2OrientationFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];
        X = [X ; rssiFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];%,node1OrientationFeatures,node2OrientationFeatures];
        y = [y ; distanceFeatures];
    end
    nans = isnan(X);
    nansRows = zeros(size(nans,1),1);
    for i=1:size(nans,2)
        nansRows = nansRows | nans(:,i);
    end
    X = X(~nansRows,:);
    y = y(~nansRows,:);
    fprintf('%d samples discarded in training because they are NaN.\n',sum(sum(nans)));
    
    lambda = options.REGULARIZATION_LAMBDA;
    p = options.POLYNOMIAL_FEATURES_DEGREE;
    %p = 1;
    %Xpower = calculatePowerFeatures(X);
    Xpoly = calculatePolynomialFeatures(X, p);
    [Xpoly, model.mu, model.sigma] = featureNormalize(Xpoly);  % Normalize
    Xpoly = [ones(size(X,1),1), Xpoly]; %add ones
    %opt = optimset('GradObj', 'on', 'MaxIter', 1000,'MaxFunEvals',1000000);
    opt = optimset('GradObj', 'off', 'MaxIter', 1000,'Display','iter-detailed','MaxFunEvals',1000000);
    tetha0 = ones(size(Xpoly,2),size(y,2));
    
    model.tetha = fminunc(@(t)(costFunction(Xpoly, y, t, lambda,options)), tetha0,opt);
    model.p = p;
    model.inputDataType = modelTypeStr;
    model.fadeModelType = options.FADE_MODEL_TO_USE;
elseif options.FADE_MODEL_TO_USE == options.ANN_MODEL_LABEL_CONSTANT
    p = options.POLYNOMIAL_FEATURES_DEGREE;
    noOfFiles = size(files,1);
    X = [];
    y = [];
    
    for fileNo = 1:noOfFiles
        
        %for linkIdx = 1:noOfLinks
        availableIds = unique([cell2mat(files{fileNo}.features.ID1) ; cell2mat(files{fileNo}.features.ID2)]);
        noOfNodes = size(availableIds,1);
        noOfLinks = noOfNodes*(noOfNodes-1)/2;
        for nodeIdUnderFocusIdx = 1:noOfNodes
            %this reorganizes the links order to be always the same
            newLinkIdx = 1;
            %newFeatures = files{fileNo}.features;
            nodeIdUnderFocus = availableIds(nodeIdUnderFocusIdx);
            nodeIdUnderFocus_2 = nodeIdUnderFocus;
            startingLinkIdxs = find(nodeIdUnderFocus == availableIds);
            
            validLinkIdx = find( (cell2mat(files{fileNo}.features.ID1) == nodeIdUnderFocus | cell2mat(files{fileNo}.features.ID2) == nodeIdUnderFocus) );
            idx = 0;
            
            for linkNo = 1:noOfLinks
                if linkNo >= size(validLinkIdx,1)
                    idx = idx + 1;
                    nodeIdUnderFocus_2 = newFeatures.ID2{idx};
                    validLinkIdx = [validLinkIdx; find( (cell2mat(files{fileNo}.features.ID1) == nodeIdUnderFocus_2 | cell2mat(files{fileNo}.features.ID2) == nodeIdUnderFocus_2) )];
                    validLinkIdx = unique(validLinkIdx,'stable');
                end
                isFlipped = files{fileNo}.features.ID2{validLinkIdx(linkNo)} == nodeIdUnderFocus_2;
                if(isFlipped)
                    newFeatures.ID1{linkNo,1} = files{fileNo}.features.ID2{validLinkIdx(linkNo)};
                    newFeatures.ID2{linkNo,1} = files{fileNo}.features.ID1{validLinkIdx(linkNo)};
                else
                    newFeatures.ID1{linkNo,1} = files{fileNo}.features.ID1{validLinkIdx(linkNo)};
                    newFeatures.ID2{linkNo,1} = files{fileNo}.features.ID2{validLinkIdx(linkNo)};
                end
                newFeatures.set{linkNo,1} = files{fileNo}.features.set{validLinkIdx(linkNo)};
                newFeatures.X.rssi{linkNo,1} = files{fileNo}.features.X.rssi{validLinkIdx(linkNo)};
                newFeatures.X.node1Orientation{linkNo,1} = files{fileNo}.features.X.node1Orientation{validLinkIdx(linkNo)};
                newFeatures.X.node2Orientation{linkNo,1} = files{fileNo}.features.X.node2Orientation{validLinkIdx(linkNo)};
                newFeatures.X.rssiStd{linkNo,1} = files{fileNo}.features.X.rssiStd{validLinkIdx(linkNo)};
                newFeatures.X.rssiMean{linkNo,1} = files{fileNo}.features.X.rssiMean{validLinkIdx(linkNo)};
                newFeatures.Y.distance{linkNo,1} = files{fileNo}.features.Y.distance{validLinkIdx(linkNo)};
                newFeatures.Y.node1AngleOfLink{linkNo,1} = files{fileNo}.features.Y.node1AngleOfLink{validLinkIdx(linkNo)};
                newFeatures.Y.node2AngleOfLink{linkNo,1} = files{fileNo}.features.Y.node2AngleOfLink{validLinkIdx(linkNo)};
            end
            newLinks = [cell2mat(newFeatures.ID1) , cell2mat(newFeatures.ID2)];
            originalLinks = [(cell2mat(files{fileNo}.features.ID1)),(cell2mat(files{fileNo}.features.ID2))];
            %end
            noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
            noOfLinks = size(files{fileNo}.features.ID1,1);
            
            %trainingSetLogicalIdx = reshape(cell2mat(newFeatures.set),noOfTimeSamples,noOfLinks) == options.TRAIN_SET_LABEL_CONSTANT;
            trainingSetLogicalIdx = reshape(cell2mat(newFeatures.set),noOfTimeSamples,noOfLinks) ~= 0; %the nn toolbox automatically split in three training sets
            distance = reshape(cell2mat(newFeatures.Y.distance),noOfTimeSamples,noOfLinks);
            rssi = reshape(cell2mat(newFeatures.X.rssi),noOfTimeSamples,noOfLinks);
            node1Orientation = reshape(cell2mat(newFeatures.X.node1Orientation),noOfTimeSamples,noOfLinks);
            node2Orientation = reshape(cell2mat(newFeatures.X.node2Orientation),noOfTimeSamples,noOfLinks);
            node1AngleOfLink = reshape(cell2mat(newFeatures.Y.node1AngleOfLink),noOfTimeSamples,noOfLinks);
            node2AngleOfLink = reshape(cell2mat(newFeatures.Y.node2AngleOfLink),noOfTimeSamples,noOfLinks);
            
            validLinksLogicalIdxX = (cell2mat(newFeatures.ID1) == nodeIdUnderFocus | cell2mat(newFeatures.ID2) == nodeIdUnderFocus)';% ones(1,size(newFeatures.ID1,1));;%ones(1,size(newFeatures.ID1,1));%(cell2mat(newFeatures.ID1) == nodeIdUnderFocus | cell2mat(newFeatures.ID2) == nodeIdUnderFocus)';% ones(1,size(newFeatures.ID1,1));
            trainingSetLogicalIdxSelectedLinksX = trainingSetLogicalIdx(:,find(validLinksLogicalIdxX));
            rssiSelectedLinks = rssi(:,find(validLinksLogicalIdxX));
            node1OrientationSelectedLinks = node1Orientation(:,find(validLinksLogicalIdxX));
            node2OrientationSelectedLinks = node2Orientation(:,find(validLinksLogicalIdxX));
            node1AngleOfLinkSelectedLinks = node1AngleOfLink(:,find(validLinksLogicalIdxX));
            node2AngleOfLinkSelectedLinks = node2AngleOfLink(:,find(validLinksLogicalIdxX));
            validLinksLogicalIdxY = (cell2mat(newFeatures.ID1) == nodeIdUnderFocus | cell2mat(newFeatures.ID2) == nodeIdUnderFocus)';% ones(1,size(newFeatures.ID1,1));
            trainingSetLogicalIdxSelectedLinksY = trainingSetLogicalIdx(:,find(validLinksLogicalIdxY));
            distanceSelectedLinks = distance(:,find(validLinksLogicalIdxY));
            
            temp = rssiSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
            rssiFeatures = reshape(temp,size(temp,1)/size(rssiSelectedLinks,2),size(rssiSelectedLinks,2));
            temp = distanceSelectedLinks(trainingSetLogicalIdxSelectedLinksY);
            distanceFeatures = reshape(temp,size(temp,1)/size(distanceSelectedLinks,2),size(distanceSelectedLinks,2));
            temp = node1OrientationSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
            node1OrientationFeatures = reshape(temp,size(temp,1)/size(node1OrientationSelectedLinks,2),size(node1OrientationSelectedLinks,2));
            temp = node2OrientationSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
            node2OrientationFeatures = reshape(temp,size(temp,1)/size(node2OrientationSelectedLinks,2),size(node2OrientationSelectedLinks,2));
            temp = node1AngleOfLinkSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
            node1AngleOfLinkFeatures = reshape(temp,size(temp,1)/size(node1AngleOfLinkSelectedLinks,2),size(node1AngleOfLinkSelectedLinks,2));
            temp = node2AngleOfLinkSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
            node2AngleOfLinkFeatures = reshape(temp,size(temp,1)/size(node2AngleOfLinkSelectedLinks,2),size(node2AngleOfLinkSelectedLinks,2));
            
            if ~isempty(distanceFeatures)
                %        X = [X ; rssiFetures,node1OrientationFeatures,node2OrientationFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];
                X = [X ; rssiFeatures];%,node1OrientationFeatures,node2OrientationFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];%,node1OrientationFeatures,node2OrientationFeatures];
                y = [y ; distanceFeatures];
            end
        end
    end
    nans = isnan(X);
    nansRows = zeros(size(nans,1),1);
    for i=1:size(nans,2)
        nansRows = nansRows | nans(:,i);
    end
    X = X(~nansRows,:);
    y = y(~nansRows,:);
    
    fprintf('%d samples discarded in training because they are NaN.\n',sum(sum(nans)));
    
    %lambda = options.REGULARIZATION_LAMBDA;
    p = options.POLYNOMIAL_FEATURES_DEGREE;
    %p = 1;
    %Xpower = calculatePowerFeatures(X);
    Xpoly = calculatePolynomialFeatures(X, p);
    %    [Xpoly, model.mu, model.sigma] = featureNormalize(Xpoly);  % Normalize
    tempnet = feedforwardnet(options.ANN_HIDDEN_LAYERS);
    tempnet.trainFcn = 'trainbr';
    %tempnet.performParam.regularization = options.REGULARIZATION_LAMBDA;
    
    if options.USE_NORMALIZED_ERROR
        tempnet.performParam.normalization = 'percent';
    end
    
    [model.net,tr] = train(tempnet,Xpoly',y','useParallel','yes');
    
    %    model.tetha = fminunc(@(t)(costFunction(Xpoly, y, t, lambda,options)), tetha0,opt);
    model.p = p;
    model.inputDataType = modelTypeStr;
    model.fadeModelType = options.FADE_MODEL_TO_USE;
    
elseif options.FADE_MODEL_TO_USE == options.ANN2_MODEL_LABEL_CONSTANT
    
    p = options.POLYNOMIAL_FEATURES_DEGREE;
    noOfFiles = size(files,1);
    X = [];
    y = [];
    sets = [];
    for fileNo = 1:noOfFiles
        
        %for linkIdx = 1:noOfLinks
        availableIds = unique([cell2mat(files{fileNo}.features.ID1) ; cell2mat(files{fileNo}.features.ID2)]);
        noOfNodes = size(availableIds,1);
        noOfLinks = noOfNodes*(noOfNodes-1)/2;
        
        
        %this reorganizes the links order to be always the same
        %newLinkIdx = 1;
        %newFeatures = files{fileNo}.features;
        %nodeIdUnderFocus = availableIds(nodeIdUnderFocusIdx);
        %nodeIdUnderFocus_2 = nodeIdUnderFocus;
        %startingLinkIdxs = find(nodeIdUnderFocus == availableIds);
        
        %validLinkIdx = find( (cell2mat(files{fileNo}.features.ID1) == nodeIdUnderFocus | cell2mat(files{fileNo}.features.ID2) == nodeIdUnderFocus) );
        idx = 0;
        triangles = nchoosek(availableIds,3);
        noOfExamples = size(files{fileNo}.features.X.rssi{1},1);

        for triangleIdx = 1:size(triangles,1)
            
            node1ID = triangles(triangleIdx,1);
            node2ID = triangles(triangleIdx,2);
            node3ID = triangles(triangleIdx,3);
            
            link1_2idx = find(cell2mat(files{fileNo}.features.ID1) == node1ID & cell2mat(files{fileNo}.features.ID2) == node2ID);
            if isempty(link1_2idx)
                link1_2idx = find(cell2mat(files{fileNo}.features.ID1) == node2ID & cell2mat(files{fileNo}.features.ID2) == node1ID);
                link1_2AngleNode1 = files{fileNo}.features.Y.node2AngleOfLink{link1_2idx};
                link1_2AngleNode2 = files{fileNo}.features.Y.node1AngleOfLink{link1_2idx};
            else
                link1_2AngleNode1 = files{fileNo}.features.Y.node1AngleOfLink{link1_2idx};
                link1_2AngleNode2 = files{fileNo}.features.Y.node2AngleOfLink{link1_2idx};
            end
            link2_3idx = find(cell2mat(files{fileNo}.features.ID1) == node2ID & cell2mat(files{fileNo}.features.ID2) == node3ID);% | cell2mat(files{fileNo}.features.ID1) == node3ID & cell2mat(files{fileNo}.features.ID2) == node2ID);
            if isempty(link2_3idx)
                link2_3idx = find(cell2mat(files{fileNo}.features.ID1) == node3ID & cell2mat(files{fileNo}.features.ID2) == node2ID);
                link2_3AngleNode1 = files{fileNo}.features.Y.node2AngleOfLink{link2_3idx};
                link2_3AngleNode2 = files{fileNo}.features.Y.node1AngleOfLink{link2_3idx};
            else
                link2_3AngleNode1 = files{fileNo}.features.Y.node1AngleOfLink{link2_3idx};
                link2_3AngleNode2 = files{fileNo}.features.Y.node2AngleOfLink{link2_3idx};
            end
            link3_1idx = find(cell2mat(files{fileNo}.features.ID1) == node3ID & cell2mat(files{fileNo}.features.ID2) == node1ID);% | cell2mat(files{fileNo}.features.ID1) == node1ID & cell2mat(files{fileNo}.features.ID2) == node3ID);
            if isempty(link3_1idx)
                link3_1idx = find(cell2mat(files{fileNo}.features.ID1) == node1ID & cell2mat(files{fileNo}.features.ID2) == node3ID);
                link3_1AngleNode1 = files{fileNo}.features.Y.node2AngleOfLink{link3_1idx};
                link3_1AngleNode2 = files{fileNo}.features.Y.node1AngleOfLink{link3_1idx};
            else
                link3_1AngleNode1 = files{fileNo}.features.Y.node1AngleOfLink{link3_1idx};
                link3_1AngleNode2 = files{fileNo}.features.Y.node2AngleOfLink{link3_1idx};
            end
            
            rssiFeatures = [files{fileNo}.features.X.rssi{link1_2idx}, files{fileNo}.features.X.rssi{link2_3idx} , files{fileNo}.features.X.rssi{link3_1idx}];
            %rssiFeatures = [files{fileNo}.features.X.rssiMean{link1_2idx}, files{fileNo}.features.X.rssiMean{link2_3idx} , files{fileNo}.features.X.rssiMean{link3_1idx}];%, files{fileNo}.features.X.rssiStd{link1_2idx}, files{fileNo}.features.X.rssiStd{link2_3idx} , files{fileNo}.features.X.rssiStd{link3_1idx}];
           
            %linksAnglesFeature = [link1_2AngleNode1, link1_2AngleNode2, link2_3AngleNode1, link2_3AngleNode2, link3_1AngleNode1, link3_1AngleNode2];
            distanceFeatures = [files{fileNo}.features.Y.distance{link1_2idx}, files{fileNo}.features.Y.distance{link2_3idx} , files{fileNo}.features.Y.distance{link3_1idx}];
            %distanceFeatures = [files{fileNo}.features.Y.distance{link1_2idx}(1), files{fileNo}.features.Y.distance{link2_3idx}(1) , files{fileNo}.features.Y.distance{link3_1idx}(1)];
            
            %node1AngleOfLinkFeatures = [files{fileNo}.features.X.rssi{link1_2idx}, files{fileNo}.features.X.rssi{link2_3idx} , files{fileNo}.features.X.rssi{link3_1idx}];
            %node2AngleOfLinkFeatures = [files{fileNo}.features.Y.distance{link1_2idx}, files{fileNo}.features.Y.distance{link2_3idx} , files{fileNo}.features.Y.distance{link3_1idx}];

            set = files{fileNo}.features.set{link1_2idx};
            if ~isempty(distanceFeatures)
                %        X = [X ; rssiFetures,node1OrientationFeatures,node2OrientationFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];
                X = [X ; rssiFeatures]; %, linksAnglesFeature];%,node1OrientationFeatures,node2OrientationFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];%,node1OrientationFeatures,node2OrientationFeatures];
                y = [y ; distanceFeatures];
                sets = [sets ; set];
            end
        end
    end
    nans = isnan(X);
    nansRows = zeros(size(nans,1),1);
    for i=1:size(nans,2)
        nansRows = nansRows | nans(:,i);
    end
    X = X(~nansRows,:);
    y = y(~nansRows,:);
    
    fprintf('%d samples discarded in training because they are NaN.\n',sum(sum(nans)));
    
    %lambda = options.REGULARIZATION_LAMBDA;
    p = options.POLYNOMIAL_FEATURES_DEGREE;
    %p = 1;
    %Xpower = calculatePowerFeatures(X);
    Xpoly = calculatePolynomialFeatures(X, p);
    %    [Xpoly, model.mu, model.sigma] = featureNormalize(Xpoly);  % Normalize
    %tempnet = network;
    tempnet = feedforwardnet(options.ANN_HIDDEN_LAYERS);
    tempnet.trainFcn = 'trainbr';
    %tempnet.performParam.regularization = options.REGULARIZATION_LAMBDA;
    
    tempnet.trainParam.max_fail = 30;
    tempnet.trainParam.mu_max = 100000000000000;
    tempnet.trainParam.epochs = 200;
    %tempnet.trainParam.showWindow = false;
    
    tempnet.divideFcn = 'divideind';
    tempnet.divideParam.trainInd = find(sets == options.TRAIN_SET_LABEL_CONSTANT);
    
    if options.MERGE_TEST_AND_CORSSVALIDATION
        tempnet.divideParam.testInd = find(sets == options.TEST_SET_LABEL_CONSTANT);
        tempnet.divideParam.valInd = tempnet.divideParam.testInd;
    else
        tempnet.divideParam.testInd = find(sets == options.TEST_SET_LABEL_CONSTANT);
        tempnet.divideParam.valInd = find(sets == options.CROSSVALIDATION_SET_LABEL_CONSTANT);
    end
    
    tempnet.performFcn = 'mse';
    if options.USE_NORMALIZED_ERROR
        tempnet.performParam.normalization = 'percent';
    end
    
    [model.net,tr] = train(tempnet,Xpoly',y','useParallel','yes');
    model.p = p;
    model.inputDataType = modelTypeStr;
    model.fadeModelType = options.FADE_MODEL_TO_USE;
end