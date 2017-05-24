function plotModelWithTrainingData(files,model,options)

noOfFiles = size(files,1);

Xtrain = [];
ytrain = [];
Xtest = [];
ytest = [];
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
    %get training set indexes
    setsMatrix = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks);
    trainingSetLogicalIdx = setsMatrix == options.TRAIN_SET_LABEL_CONSTANT;
    if options.MERGE_TEST_AND_CORSSVALIDATION
        crossValidationSetLogicalIdx = (setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT) | (setsMatrix == options.TEST_SET_LABEL_CONSTANT) ;
        testSetLogicalIdx = (setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT) | (setsMatrix == options.TEST_SET_LABEL_CONSTANT) ;
    else
        %get cross validation set indexes
        crossValidationSetLogicalIdx = setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT;
        %get test set indexes
        testSetLogicalIdx = setsMatrix == options.TEST_SET_LABEL_CONSTANT;
    end
    
    
    if strcmp(model.inputDataType,options.RSSI_AND_ORIENTATION_DATA)
        node1Orientation = reshape(cell2mat(files{fileNo}.features.X.node1Orientation),noOfTimeSamples,noOfLinks);
        node2Orientation = reshape(cell2mat(files{fileNo}.features.X.node2Orientation),noOfTimeSamples,noOfLinks);
        Xtrain = [Xtrain ; rssi(trainingSetLogicalIdx) , node1Orientation(trainingSetLogicalIdx), node2Orientation(trainingSetLogicalIdx)];
        Xcrossvalidation = [Xcrossvalidation ; rssi(crossValidationSetLogicalIdx) , node1Orientation(crossValidationSetLogicalIdx), node2Orientation(crossValidationSetLogicalIdx)];
        Xtest = [Xtest ; rssi(testSetLogicalIdx) , node1Orientation(testSetLogicalIdx), node2Orientation(testSetLogicalIdx)];
    elseif strcmp(model.inputDataType,options.ONLY_RSSI_DATA)
        %concatenate training set
        Xtrain = [Xtrain ; rssi(trainingSetLogicalIdx)];
        
        %concatenate test set
        Xcrossvalidation = [Xcrossvalidation ; rssi(crossValidationSetLogicalIdx)];
        
        %concatenate test set
        Xtest = [Xtest ; rssi(testSetLogicalIdx)];
        
    end
    ytrain = [ytrain ; distance(trainingSetLogicalIdx)];
    ycrossvalidation = [ycrossvalidation ; distance(crossValidationSetLogicalIdx)];
    ytest = [ytest ; distance(testSetLogicalIdx)];
end

if model.fadeModelType == options.POLY_FADE_MODEL_LABEL_CONSTANT || model.fadeModelType==options.LOG_FADE_MODEL_LABEL_CONSTANT
    if strcmp(model.inputDataType,options.ONLY_RSSI_DATA)
        RSSIForPlotModel = (-30:-1:-100)';
        
        p=model.p;
        if model.fadeModelType == options.POLY_FADE_MODEL_LABEL_CONSTANT
            %Xpower = calculatePowerFeatures(RSSIForPlotModel);
            RSSIForPlotModelpoly = calculatePolynomialFeatures(RSSIForPlotModel, p);
        elseif model.fadeModelType == options.LOG_FADE_MODEL_LABEL_CONSTANT
            RSSIForPlotModelpoly = RSSIForPlotModel;
        end
        
        RSSIForPlotModelpolynorm = featureNormalize(RSSIForPlotModelpoly, model);
        
        RSSIForPlotModelpolynorm = [ones(size(RSSIForPlotModelpoly,1),1), RSSIForPlotModelpolynorm];
        
        distanceForPlotModel = fadeHypothesis(RSSIForPlotModelpolynorm,model.tetha,options);
        figure
        plot(distanceForPlotModel,RSSIForPlotModel)
        hold on;
        plot(ytrain,Xtrain,'.',ytest,Xtest,'.',ycrossvalidation,Xcrossvalidation,'.')
        legend('Model','Train set','Test set','Cross Validation set');
        hold off;
        axis([0, 50,options.RSSI_AXIS_MIN_VALUE, options.RSSI_AXIS_MAX_VALUE]);
        grid on
        xlabel('Link distance [m]');
        ylabel('Link RSSI [dBm]');
    end
end
fprintf('Total amount of samples: %d\n',totalAmoutOfSamples);
fprintf('Model trained with %d training samples.\n',size(Xtrain,1));
fprintf('Cross Validation set with %d training samples.\n',size(Xcrossvalidation,1));
fprintf('Test set with %d training samples.\n\n',size(Xtest,1));

if isfield(model,'trainError')
    fprintf('Model error (MSE) on Training Set: %.2fm.\n',model.trainError.meters);
    fprintf('Model error (MSE) on Training Set: %.2fpercent.\n\n',model.trainError.percentage);
end

if isfield(model,'crossVError')
    fprintf('Model error (MSE) on Cross Validation Set: %.2fm.\n',model.crossVError.meters);
    fprintf('Model error (MSE) on Cross Validation Set: %.2fpercent.\n\n',model.crossVError.percentage);
end

if isfield(model,'testError')
    fprintf('Model error (MSE) on Test Set: %.2fm.\n',model.testError.meters);
    fprintf('Model error (MSE) on Test Set: %.2fpercent.\n',model.testError.percentage);
end

end