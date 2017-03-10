function err = calculateError(files,model,options,setSelectionStr)

if strcmp(setSelectionStr,'Train')
    noOfFiles = size(files,1);
    
    Xtrain = [];
    ytrain = [];
    totalAmoutOfSamples = 0;
    for fileNo = 1:noOfFiles
        %prepare variables
        noOfLinks = size(files{fileNo}.features.ID1,1);
        noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
        distance = reshape(cell2mat(files{fileNo}.features.Y.distance),noOfTimeSamples,noOfLinks);
        rssi = reshape(cell2mat(files{fileNo}.features.X.rssi),noOfTimeSamples,noOfLinks);
        totalAmoutOfSamples = totalAmoutOfSamples + size(rssi,1)*size(rssi,2);
        %get training set indexes
        trainingSetLogicalIdx = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks) == options.TRAIN_SET_LABEL_CONSTANT;
        
        %concatenate training set
        if strcmp(model.inputDataType,options.RSSI_AND_ORIENTATION_DATA)
            node1Orientation = reshape(cell2mat(files{fileNo}.features.X.node1Orientation),noOfTimeSamples,noOfLinks);
            node2Orientation = reshape(cell2mat(files{fileNo}.features.X.node2Orientation),noOfTimeSamples,noOfLinks);
            Xtrain = [Xtrain ; rssi(trainingSetLogicalIdx) , node1Orientation(trainingSetLogicalIdx), node2Orientation(trainingSetLogicalIdx)];
            
            %             node1AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node1AngleOfLink),noOfTimeSamples,noOfLinks);
            %             node2AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node2AngleOfLink),noOfTimeSamples,noOfLinks);
            %             Xtrain = [Xtrain ; rssi(trainingSetLogicalIdx) , node1Orientation(trainingSetLogicalIdx), node2Orientation(trainingSetLogicalIdx), node1AngleOfLink(trainingSetLogicalIdx) ,node2AngleOfLink(trainingSetLogicalIdx)];
        elseif strcmp(model.inputDataType,options.ONLY_RSSI_DATA)
            Xtrain = [Xtrain ; rssi(trainingSetLogicalIdx)];
        end
        ytrain = [ytrain ; distance(trainingSetLogicalIdx)];
    end
    
    p=model.p;
    if model.fadeModelType == options.POLY_FADE_MODEL_LABEL_CONSTANT
        %Xpower = calculatePowerFeatures(Xtrain);
        XTrainVPoly = calculatePolynomialFeatures(Xtrain, p);
    elseif model.fadeModelType == options.LOG_FADE_MODEL_LABEL_CONSTANT
        XTrainVPoly = Xtrain;
    end
    
    [XTrainNorm, ~, ~] = featureNormalize(XTrainVPoly,model);
    
    XTrainNorm = [ones(size(XTrainVPoly,1),1), XTrainNorm];
    
    yPredicted = fadeHypothesis(XTrainNorm,model.tetha,options);
    
    predictionError = yPredicted-ytrain;
    predictionError(isnan(predictionError)) = 0;
    
    predictionErrorPercent = predictionError./ytrain;
    
    err.meters = 1/size(predictionError,1)*(predictionError'*predictionError);
    err.percentage = 1/size(predictionError,1)*(predictionErrorPercent'*predictionErrorPercent)*100;
    
elseif strcmp(setSelectionStr,'CrossValidation')
    noOfFiles = size(files,1);
    
    Xcrossvalidation = [];
    ycrossvalidation = [];
    totalAmoutOfSamples = 0;
    for fileNo = 1:noOfFiles
        %prepare variables
        noOfLinks = size(files{fileNo}.features.ID1,1);
        noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
        distance = reshape(cell2mat(files{fileNo}.features.Y.distance),noOfTimeSamples,noOfLinks);
        rssi = reshape(cell2mat(files{fileNo}.features.X.rssi),noOfTimeSamples,noOfLinks);
        totalAmoutOfSamples = totalAmoutOfSamples + size(rssi,1)*size(rssi,2);
        %get cross validation set indexes
        crossValidationSetLogicalIdx = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks) == options.CROSSVALIDATION_SET_LABEL_CONSTANT;
        
        %concatenate test set
        if strcmp(model.inputDataType,options.RSSI_AND_ORIENTATION_DATA)
            node1Orientation = reshape(cell2mat(files{fileNo}.features.X.node1Orientation),noOfTimeSamples,noOfLinks);
            node2Orientation = reshape(cell2mat(files{fileNo}.features.X.node2Orientation),noOfTimeSamples,noOfLinks);
            Xcrossvalidation = [Xcrossvalidation ; rssi(crossValidationSetLogicalIdx) , node1Orientation(crossValidationSetLogicalIdx), node2Orientation(crossValidationSetLogicalIdx)];
            
            %             node1AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node1AngleOfLink),noOfTimeSamples,noOfLinks);
            %             node2AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node2AngleOfLink),noOfTimeSamples,noOfLinks);
            %             Xcrossvalidation = [Xcrossvalidation ; rssi(crossValidationSetLogicalIdx) , node1Orientation(crossValidationSetLogicalIdx), node2Orientation(crossValidationSetLogicalIdx),node1AngleOfLink(crossValidationSetLogicalIdx) , node2AngleOfLink(crossValidationSetLogicalIdx) ];
        elseif strcmp(model.inputDataType,options.ONLY_RSSI_DATA)
            Xcrossvalidation = [Xcrossvalidation ; rssi(crossValidationSetLogicalIdx)];
        end
        ycrossvalidation = [ycrossvalidation ; distance(crossValidationSetLogicalIdx)];
    end
    
    p=model.p;
    if model.fadeModelType == options.POLY_FADE_MODEL_LABEL_CONSTANT
        %XCrossVPoly = calculatePowerFeatures(Xcrossvalidation);
        XCrossVPoly = calculatePolynomialFeatures(Xcrossvalidation, p);
    elseif model.fadeModelType == options.LOG_FADE_MODEL_LABEL_CONSTANT
        XCrossVPoly = Xcrossvalidation;
    end
    
    [XCrossVNorm, ~, ~] = featureNormalize(XCrossVPoly,model);
    
    XCrossVNorm = [ones(size(XCrossVPoly,1),1), XCrossVNorm];
    
    yPredicted = fadeHypothesis(XCrossVNorm,model.tetha,options);
    
    predictionError = yPredicted-ycrossvalidation;
    predictionError(isnan(predictionError)) = 0;
    
    predictionErrorPercent = predictionError./ycrossvalidation;
    
    err.meters = 1/size(predictionError,1)*(predictionError'*predictionError);
    err.percentage = 1/size(predictionError,1)*(predictionErrorPercent'*predictionErrorPercent)*100;
elseif strcmp(setSelectionStr,'Test')
    noOfFiles = size(files,1);
    
    Xtest = [];
    ytest = [];
    totalAmoutOfSamples = 0;
    for fileNo = 1:noOfFiles
        %prepare variables
        noOfLinks = size(files{fileNo}.features.ID1,1);
        noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
        distance = reshape(cell2mat(files{fileNo}.features.Y.distance),noOfTimeSamples,noOfLinks);
        rssi = reshape(cell2mat(files{fileNo}.features.X.rssi),noOfTimeSamples,noOfLinks);
        totalAmoutOfSamples = totalAmoutOfSamples + size(rssi,1)*size(rssi,2);
        
        %get test set indexes
        testSetLogicalIdx = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks) == options.TEST_SET_LABEL_CONSTANT;
        
        %concatenate test set
        if strcmp(model.inputDataType,options.RSSI_AND_ORIENTATION_DATA)
            node1Orientation = reshape(cell2mat(files{fileNo}.features.X.node1Orientation),noOfTimeSamples,noOfLinks);
            node2Orientation = reshape(cell2mat(files{fileNo}.features.X.node2Orientation),noOfTimeSamples,noOfLinks);
            
            Xtest = [Xtest ; rssi(testSetLogicalIdx) , node1Orientation(testSetLogicalIdx), node2Orientation(testSetLogicalIdx)];
            
            %             node1AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node1AngleOfLink),noOfTimeSamples,noOfLinks);
            %             node2AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node2AngleOfLink),noOfTimeSamples,noOfLinks);
            %             Xtest = [Xtest ; rssi(testSetLogicalIdx) , node1Orientation(testSetLogicalIdx), node2Orientation(testSetLogicalIdx),node1AngleOfLink(testSetLogicalIdx) , node2AngleOfLink(testSetLogicalIdx) ];
        elseif strcmp(model.inputDataType,options.ONLY_RSSI_DATA)
            Xtest = [Xtest ; rssi(testSetLogicalIdx)];
        end
        ytest = [ytest ; distance(testSetLogicalIdx)];
    end
    
    p=model.p;
    if model.fadeModelType == options.POLY_FADE_MODEL_LABEL_CONSTANT
        %XCrossVPoly = calculatePowerFeatures(Xcrossvalidation);
        XTestPoly = calculatePolynomialFeatures(Xtest, p);
    elseif model.fadeModelType == options.LOG_FADE_MODEL_LABEL_CONSTANT
        XTestPoly = Xtest;
    end
    
    [XTestNorm, ~, ~] = featureNormalize(XTestPoly,model);
    
    XTestNorm = [ones(size(XTestPoly,1),1), XTestNorm];
    
    yPredicted = fadeHypothesis(XTestNorm,model.tetha,options);
    
    predictionError = yPredicted-ytest;
    predictionError(isnan(predictionError)) = 0;
    
    predictionErrorPercent = predictionError./ytest;
    
    err.meters = 1/size(predictionError,1)*(predictionError'*predictionError);
    err.percentage = 1/size(predictionError,1)*(predictionErrorPercent'*predictionErrorPercent)*100;
else
    error('setSelectionStr must be Train, CrossValidation or Test');
end