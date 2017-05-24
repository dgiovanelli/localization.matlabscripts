function err = calculateError(files,model,options,setSelectionStr)
enablePlot = false;
noOfFiles = size(files,1);

X = [];
y = [];
totalAmoutOfSamples = 0;

if options.FADE_MODEL_TO_USE == options.POLY_FADE_MODEL_LABEL_CONSTANT || options.FADE_MODEL_TO_USE == options.LOG_FADE_MODEL_LABEL_CONSTANT
    for fileNo = 1:noOfFiles
        %prepare variables
        noOfLinks = size(files{fileNo}.features.ID1,1);
        noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
        distance = reshape(cell2mat(files{fileNo}.features.Y.distance),noOfTimeSamples,noOfLinks);
        rssi = reshape(cell2mat(files{fileNo}.features.X.rssi),noOfTimeSamples,noOfLinks);
        totalAmoutOfSamples = totalAmoutOfSamples + size(rssi,1)*size(rssi,2);
        %get training set indexes
        setsMatrix = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks);
        if strcmp(setSelectionStr,'Train')
            trainingSetLogicalIdx = setsMatrix == options.TRAIN_SET_LABEL_CONSTANT;
        elseif strcmp(setSelectionStr,'All')
            trainingSetLogicalIdx = setsMatrix ~= 0;
        else
            if options.MERGE_TEST_AND_CORSSVALIDATION
                trainingSetLogicalIdx = (setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT) | (setsMatrix == options.TEST_SET_LABEL_CONSTANT) ;
            else
                if strcmp(setSelectionStr,'CrossValidation')
                    trainingSetLogicalIdx = setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT;
                elseif strcmp(setSelectionStr,'Test')
                    trainingSetLogicalIdx = setsMatrix == options.TEST_SET_LABEL_CONSTANT;
                else
                    error('invalid setSelectionStr');
                end
            end
        end
        %concatenate training set
        if strcmp(model.inputDataType,options.RSSI_AND_ORIENTATION_DATA)
            node1Orientation = reshape(cell2mat(files{fileNo}.features.X.node1Orientation),noOfTimeSamples,noOfLinks);
            node2Orientation = reshape(cell2mat(files{fileNo}.features.X.node2Orientation),noOfTimeSamples,noOfLinks);
            X = [X ; rssi(trainingSetLogicalIdx) , node1Orientation(trainingSetLogicalIdx), node2Orientation(trainingSetLogicalIdx)];
            
            %             node1AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node1AngleOfLink),noOfTimeSamples,noOfLinks);
            %             node2AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node2AngleOfLink),noOfTimeSamples,noOfLinks);
            %             Xtrain = [Xtrain ; rssi(trainingSetLogicalIdx) , node1Orientation(trainingSetLogicalIdx), node2Orientation(trainingSetLogicalIdx), node1AngleOfLink(trainingSetLogicalIdx) ,node2AngleOfLink(trainingSetLogicalIdx)];
        elseif strcmp(model.inputDataType,options.ONLY_RSSI_DATA)
            X = [X ; rssi(trainingSetLogicalIdx)];
        end
        y = [y ; distance(trainingSetLogicalIdx)];
    end
    
    p=model.p;
    if model.fadeModelType == options.POLY_FADE_MODEL_LABEL_CONSTANT
        %Xpower = calculatePowerFeatures(Xtrain);
        XPoly = calculatePolynomialFeatures(X, p);
    elseif model.fadeModelType == options.LOG_FADE_MODEL_LABEL_CONSTANT
        XPoly = X;
    end
    
    [XNorm, ~, ~] = featureNormalize(XPoly,model);
    
    XNorm = [ones(size(XPoly,1),1), XNorm];
    
    yPredicted = fadeHypothesis(XNorm,model.tetha,options);
    if enablePlot
        figure
        plot(1:1:size(yPredicted(:),1),yPredicted(:) , 1:1:size(y(:),1),y(:))
        grid on;
        legend('predicted','ground truth');
    end
    predictionError = yPredicted-y;
    predictionError(isnan(predictionError)) = 0;
    
    predictionErrorNorm = predictionError./y;
    
    err.mse = sqrt(1/(size(predictionError,1)*size(predictionError,2))*sum(sum(predictionError.^2)));
    err.nmse = sqrt(1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(predictionErrorNorm.^2)));
    err.nmae = 1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(abs(predictionErrorNorm)));
    
elseif options.FADE_MODEL_TO_USE == options.POLY2_MODEL_LABEL_CONSTANT
    for fileNo = 1:noOfFiles
        %prepare variables
        noOfLinks = size(files{fileNo}.features.ID1,1);
        noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
        
        nodeIdUnderFocus = 33;
        %this reorganizes the links order to be always the same
        newLinkIdx = 1;
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
                
                newFeatures = files{fileNo}.features;
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
        
        %get training set indexes
        setsMatrix = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks);
        if strcmp(setSelectionStr,'Train')
            trainingSetLogicalIdx = setsMatrix == options.TRAIN_SET_LABEL_CONSTANT;
        elseif strcmp(setSelectionStr,'All')
            trainingSetLogicalIdx = setsMatrix ~= 0;
        else
            if options.MERGE_TEST_AND_CORSSVALIDATION
                
                trainingSetLogicalIdx = (setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT) | (setsMatrix == options.TEST_SET_LABEL_CONSTANT) ;
            else
                if strcmp(setSelectionStr,'CrossValidation')
                    trainingSetLogicalIdx = setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT;
                elseif strcmp(setSelectionStr,'Test')
                    trainingSetLogicalIdx = setsMatrix == options.TEST_SET_LABEL_CONSTANT;
                else
                    error('invalid setSelectionStr');
                end
            end
        end
        
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
    
    p=model.p;
    %Xpower = calculatePowerFeatures(Xtrain);
    XPoly = calculatePolynomialFeatures(X, p);
    
    [XNorm, ~, ~] = featureNormalize(XPoly,model);
    
    XNorm = [ones(size(XPoly,1),1), XNorm];
    
    yPredicted = fadeHypothesis(XNorm,model.tetha,options);
    
    if enablePlot
        figure
        plot(1:1:size(yPredicted(:),1),yPredicted(:) , 1:1:size(y(:),1),y(:))
        grid on;
        legend('predicted','ground truth');
    end
    
    predictionError = yPredicted-y;
    predictionError(isnan(predictionError)) = 0;
    
    predictionErrorNorm = predictionError./y;
    
    err.mse = sqrt(1/(size(predictionError,1)*size(predictionError,2))*sum(sum(predictionError.^2)));
    err.nmse = sqrt(1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(predictionErrorNorm.^2)));
    err.nmae = 1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(abs(predictionErrorNorm)));
    
elseif options.FADE_MODEL_TO_USE == options.ANN_MODEL_LABEL_CONSTANT
    
    
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
            
            %get training set indexes
                    setsMatrix = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks);
        if strcmp(setSelectionStr,'Train')
            trainingSetLogicalIdx = setsMatrix == options.TRAIN_SET_LABEL_CONSTANT;
        elseif strcmp(setSelectionStr,'All')
            trainingSetLogicalIdx = setsMatrix ~= 0;
        else
            if options.MERGE_TEST_AND_CORSSVALIDATION
                
                trainingSetLogicalIdx = (setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT) | (setsMatrix == options.TEST_SET_LABEL_CONSTANT) ;
            else
                if strcmp(setSelectionStr,'CrossValidation')
                    trainingSetLogicalIdx = setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT;
                elseif strcmp(setSelectionStr,'Test')
                    trainingSetLogicalIdx = setsMatrix == options.TEST_SET_LABEL_CONSTANT;
                else
                    error('invalid setSelectionStr');
                end
            end
        end
            
            %trainingSetLogicalIdx = reshape(cell2mat(newFeatures.set),noOfTimeSamples,noOfLinks) ~= 0; %the nn toolbox automatically split in three training sets
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
    
    p=model.p;
    %Xpower = calculatePowerFeatures(Xtrain);
    XPoly = calculatePolynomialFeatures(X, p);
    
    %[XNorm, ~, ~] = featureNormalize(XPoly,model);
    XNorm = XPoly;
    %XNorm = [ones(size(XPoly,1),1), XNorm];
    
    yPredicted = sim(model.net,XNorm')';
    
    if enablePlot
        figure
        plot(1:1:size(yPredicted(:),1),yPredicted(:) , 1:1:size(y(:),1),y(:))
        grid on;
        legend('predicted','ground truth');
    end
    
    predictionError = yPredicted-y;
    predictionError(isnan(predictionError)) = 0;
    
    predictionErrorNorm = predictionError./y;
    
    err.mse = sqrt(1/(size(predictionError,1)*size(predictionError,2))*sum(sum(predictionError.^2)));
    err.nmse = sqrt(1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(predictionErrorNorm.^2)));
    err.nmae = 1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(abs(predictionErrorNorm)));
elseif options.FADE_MODEL_TO_USE == options.ANN2_MODEL_LABEL_CONSTANT
    
    
    p = options.POLYNOMIAL_FEATURES_DEGREE;
    noOfFiles = size(files,1);
    X = [];
    y = [];
    linksRec = [];
    filesRec = [];
    triangleRec = [];
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
            
            %if (strcmp(setSelectionStr,'Train') && files{fileNo}.features.set{1}(1) == options.TRAIN_SET_LABEL_CONSTANT) ||(strcmp(setSelectionStr,'CrossValidation') && files{fileNo}.features.set{1}(1) == options.CROSSVALIDATION_SET_LABEL_CONSTANT) || (strcmp(setSelectionStr,'Test') && files{fileNo}.features.set{1}(1) == options.TEST_SET_LABEL_CONSTANT)  || strcmp(setSelectionStr,'All')
            if (strcmp(setSelectionStr,'Train') && (files{fileNo}.features.set{link1_2idx}(1) == options.TRAIN_SET_LABEL_CONSTANT) && (files{fileNo}.features.set{link2_3idx}(1) == options.TRAIN_SET_LABEL_CONSTANT)  && (files{fileNo}.features.set{link3_1idx}(1) == options.TRAIN_SET_LABEL_CONSTANT)) || ...
                    (( (strcmp(setSelectionStr,'CrossValidation') || strcmp(setSelectionStr,'Test')) && options.MERGE_TEST_AND_CORSSVALIDATION) && (files{fileNo}.features.set{link1_2idx}(1) == options.CROSSVALIDATION_SET_LABEL_CONSTANT) && (files{fileNo}.features.set{link2_3idx}(1) == options.CROSSVALIDATION_SET_LABEL_CONSTANT)  && (files{fileNo}.features.set{link3_1idx}(1) == options.CROSSVALIDATION_SET_LABEL_CONSTANT)) || ...
                    (( (strcmp(setSelectionStr,'CrossValidation') || strcmp(setSelectionStr,'Test'))  && options.MERGE_TEST_AND_CORSSVALIDATION) && (files{fileNo}.features.set{link1_2idx}(1) == options.TEST_SET_LABEL_CONSTANT) && (files{fileNo}.features.set{link2_3idx}(1) == options.TEST_SET_LABEL_CONSTANT)  && (files{fileNo}.features.set{link3_1idx}(1) == options.TEST_SET_LABEL_CONSTANT))
                
                rssiFeatures = [files{fileNo}.features.X.rssi{link1_2idx}, files{fileNo}.features.X.rssi{link2_3idx} , files{fileNo}.features.X.rssi{link3_1idx}];
                %rssiFeatures = [files{fileNo}.features.X.rssiMean{link1_2idx}, files{fileNo}.features.X.rssiMean{link2_3idx} , files{fileNo}.features.X.rssiMean{link3_1idx}];%, files{fileNo}.features.X.rssiStd{link1_2idx}, files{fileNo}.features.X.rssiStd{link2_3idx} , files{fileNo}.features.X.rssiStd{link3_1idx}];
                
                %linksAnglesFeature = [link1_2AngleNode1, link1_2AngleNode2, link2_3AngleNode1, link2_3AngleNode2, link3_1AngleNode1, link3_1AngleNode2];
                distanceFeatures = [files{fileNo}.features.Y.distance{link1_2idx}, files{fileNo}.features.Y.distance{link2_3idx} , files{fileNo}.features.Y.distance{link3_1idx}];
                %distanceFeatures = [files{fileNo}.features.Y.distance{link1_2idx}(1), files{fileNo}.features.Y.distance{link2_3idx}(1) , files{fileNo}.features.Y.distance{link3_1idx}(1)];
                
                %node1AngleOfLinkFeatures = [files{fileNo}.features.X.rssi{link1_2idx}, files{fileNo}.features.X.rssi{link2_3idx} , files{fileNo}.features.X.rssi{link3_1idx}];
                %node2AngleOfLinkFeatures = [files{fileNo}.features.Y.distance{link1_2idx}, files{fileNo}.features.Y.distance{link2_3idx} , files{fileNo}.features.Y.distance{link3_1idx}];
                %no division in sets for now
                
                set = files{fileNo}.features.set{link1_2idx};
                if ~isempty(distanceFeatures)
                    %        X = [X ; rssiFetures,node1OrientationFeatures,node2OrientationFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];
                    X = [X ; rssiFeatures ];%, linksAnglesFeature];%,node1OrientationFeatures,node2OrientationFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];%,node1OrientationFeatures,node2OrientationFeatures];
                    y = [y ; distanceFeatures];
                    linksRec = [linksRec ; link1_2idx*ones(size(rssiFeatures,1),1), link2_3idx*ones(size(rssiFeatures,1),1), link3_1idx*ones(size(rssiFeatures,1),1)];
                    filesRec = [filesRec ; fileNo*ones(size(rssiFeatures,1),1)];
                    triangleRec = [triangleRec ; triangleIdx*ones(size(rssiFeatures,1),1)];                  
                end
            end
        end
    end
    nans = isnan(X);
    nansRows = zeros(size(nans,1),1);
    for i=1:size(nans,2)
        nansRows = nansRows | nans(:,i);
    end
    %     X = X(~nansRows,:);
    %     y = y(~nansRows,:);
    %     linksRec = linksRec(~nansRows,:);
    %     filesRec = filesRec(~nansRows,:);
    %     triangleRec = triangleRec(~nansRows,:);
    
    p=model.p;
    %Xpower = calculatePowerFeatures(Xtrain);
    XPoly = calculatePolynomialFeatures(X, p);
    
    %[XNorm, ~, ~] = featureNormalize(XPoly,model);
    XNorm = XPoly;
    %XNorm = [ones(size(XPoly,1),1), XNorm];
    
    yPredicted = sim(model.net,XNorm')';
    
    %reconstruct unidirectional links
    distanceEstim = [];
    distanceGroundTruth = [];
    availableFiles = unique(filesRec);
    for fileI = 1 : size(availableFiles,1)
        
        selectIThFileData = filesRec == availableFiles(fileI);
        fileLength = size(selectIThFileData,1);
        selectIThTriangleData = zeros(fileLength,1);
        availablesTriangles = unique(triangleRec(selectIThFileData));
        availableLinks = unique(linksRec(selectIThFileData,:));
        noOfLinks = size(availableLinks,1);
        noOfTrianglesToAverage = zeros(noOfLinks,1);
        noOfTriangles = size(availablesTriangles,1);
        distanceEstimFileAccumulator = zeros(sum(selectIThFileData)/noOfTriangles,noOfLinks);
        distanceEstimFile = NaN*ones(sum(selectIThFileData)/noOfTriangles,noOfLinks,10);
        distanceGroundTruthFile = zeros(sum(selectIThFileData)/noOfTriangles,noOfLinks);
        linksRecFile = linksRec(selectIThFileData,:);
        yPredictedFile = yPredicted(selectIThFileData,:);
        yFile = y(selectIThFileData,:);
        for triangleI = 1 : noOfTriangles
            
            selectIThTriangleData = triangleRec(selectIThFileData) == availablesTriangles(triangleI);
            
            link1_2idx = unique(linksRecFile( selectIThTriangleData, 1));
            link2_3idx = unique(linksRecFile( selectIThTriangleData, 2));
            link3_1idx = unique(linksRecFile( selectIThTriangleData, 3));
            
            %             distanceEstimFile(selectIThTriangleData,availableLinks == link1_2idx) = distanceEstimFile(selectIThTriangleData,availableLinks == link1_2idx) + yPredictedFile( selectIThTriangleData, 1);
            %             distanceEstimFile(selectIThTriangleData,availableLinks == link2_3idx) = distanceEstimFile(selectIThTriangleData,availableLinks == link2_3idx) + yPredictedFile( selectIThTriangleData, 2);
            %             distanceEstimFile(selectIThTriangleData,availableLinks == link3_1idx) = distanceEstimFile(selectIThTriangleData,availableLinks == link3_1idx) + yPredictedFile( selectIThTriangleData, 3);
            
            distanceEstimFileAccumulator(:,availableLinks == link1_2idx) = distanceEstimFileAccumulator(:,availableLinks == link1_2idx) + yPredictedFile( selectIThTriangleData, 1);
            distanceEstimFileAccumulator(:,availableLinks == link2_3idx) = distanceEstimFileAccumulator(:,availableLinks == link2_3idx) + yPredictedFile( selectIThTriangleData, 2);
            distanceEstimFileAccumulator(:,availableLinks == link3_1idx) = distanceEstimFileAccumulator(:,availableLinks == link3_1idx) + yPredictedFile( selectIThTriangleData, 3);
            
            distanceEstimFile(:,availableLinks == link1_2idx,noOfTrianglesToAverage(availableLinks == link1_2idx,1)+1) = yPredictedFile( selectIThTriangleData, 1);
            distanceEstimFile(:,availableLinks == link2_3idx,noOfTrianglesToAverage(availableLinks == link2_3idx,1)+1) = yPredictedFile( selectIThTriangleData, 2);
            distanceEstimFile(:,availableLinks == link3_1idx,noOfTrianglesToAverage(availableLinks == link3_1idx,1)+1) = yPredictedFile( selectIThTriangleData, 3);
            
            distanceGroundTruthFile(:,availableLinks == link1_2idx) = distanceGroundTruthFile(:,availableLinks == link1_2idx) + yFile( selectIThTriangleData, 1);
            distanceGroundTruthFile(:,availableLinks == link2_3idx) = distanceGroundTruthFile(:,availableLinks == link2_3idx) + yFile( selectIThTriangleData, 2);
            distanceGroundTruthFile(:,availableLinks == link3_1idx) = distanceGroundTruthFile(:,availableLinks == link3_1idx) + yFile( selectIThTriangleData, 3);
            
            noOfTrianglesToAverage(availableLinks == link1_2idx,1) = noOfTrianglesToAverage(availableLinks == link1_2idx,1) + 1;
            noOfTrianglesToAverage(availableLinks == link2_3idx,1) = noOfTrianglesToAverage(availableLinks == link2_3idx,1) + 1;
            noOfTrianglesToAverage(availableLinks == link3_1idx,1) = noOfTrianglesToAverage(availableLinks == link3_1idx,1) + 1;
            
            %             figure;
            %             histogram(yPredictedFile( selectIThTriangleData, 1))
            %             titleStr = sprintf('Link Length %.2f, estimation mean: ',mean(yFile( selectIThTriangleData, 1)));
            %             title(titleStr);
            %             figure;
            %             histogram(yPredictedFile( selectIThTriangleData, 2))
            %             titleStr = sprintf('Link Length %.2f',mean(yFile( selectIThTriangleData, 2)));
            %             title(titleStr);
            %             figure;
            %             histogram(yPredictedFile( selectIThTriangleData, 3))
            %             titleStr = sprintf('Link Length %.2f',mean(yFile( selectIThTriangleData, 3)));
            %             title(titleStr);
            %
            %             selectIThFileData(:) = 0;
            %             selectIThTriangleData(:) = 0;
        end
        %         distanceEstimFile = distanceEstimFile(selectIThFileData & selectIThTriangleData,:);
        %         distanceGroundTruthFile = distanceGroundTruthFile(selectIThFileData & selectIThTriangleData,:);
        % noOfTrianglesToAverage = noOfTrianglesToAverage(selectIThFileData & selectIThTriangleData,:);
        
        distanceEstimFile = distanceEstimFile(:,:,1:mean(noOfTrianglesToAverage));
        distanceEstimFileAggregated = zeros(size(distanceEstimFileAccumulator));
        for linkNo = 1 : size(noOfTrianglesToAverage,1)
            distanceEstimFileAggregated(:,linkNo) = aggregateLinkLengthEstimations( distanceEstimFile(:,linkNo,:) , options);
            distanceGroundTruthFile(:,linkNo) = distanceGroundTruthFile(:,linkNo) / noOfTrianglesToAverage(linkNo,1);
        end
        
        distanceEstim = [distanceEstim; distanceEstimFileAggregated];
        distanceGroundTruth = [distanceGroundTruth; distanceGroundTruthFile];
    end
    
    if enablePlot
        figure
        plot(1:1:size(distanceEstim(:),1),distanceEstim(:) , 1:1:size(distanceGroundTruth(:),1),distanceGroundTruth(:))
        grid on;
        legend('predicted','ground truth');
    end
    
    predictionError = distanceEstim-distanceGroundTruth;
    predictionError(isnan(predictionError)) = 0;
    
    predictionErrorNorm = predictionError./distanceGroundTruth;
    
    err.mse = sqrt(1/(size(predictionError,1)*size(predictionError,2))*sum(sum(predictionError.^2)));
    err.nmse = sqrt(1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(predictionErrorNorm.^2)));
    err.nmae = 1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(abs(predictionErrorNorm)));
end
