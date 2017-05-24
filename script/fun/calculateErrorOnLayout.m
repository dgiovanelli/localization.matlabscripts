function err = calculateErrorOnLayout(file,options,layoutNo)
    if layoutNo < 1 || layoutNo > size(file{1}.layout,2)
        error('Not valid value for layoutNo, number of available layouts: %d',size(file{1}.layout,2));
    end

    %TODO: check if file{__} has features.Y
    
    noOfFile = size(file,1);
    %     err.mse = 0;
    %     err.rmse = 0;
    %     err.rmae = 0;
    totNoOfSamples = 0;
    for fileIdx = 1:noOfFile
        noOfSamples = size(file{fileIdx}.layout{layoutNo},1);
        for sampleNo = 1:noOfSamples
            nodesId = file{fileIdx}.layout{layoutNo}{sampleNo}.id;
            noOfNodes = size(nodesId,1);
            noOfBiLink = noOfNodes*(noOfNodes-1)/2;
            totNoOfSamples = totNoOfSamples + noOfBiLink;
        end
    end
    linkSampleNo = 1;
    distanceEstim = zeros(totNoOfSamples,1);
    distanceGroundTruth = zeros(totNoOfSamples,1);
    for fileIdx = 1:noOfFile
        noOfSamples = size(file{fileIdx}.layout{layoutNo},1);
        for sampleNo = 1:noOfSamples
            nodesId = file{fileIdx}.layout{layoutNo}{sampleNo}.id;
            noOfNodes = size(nodesId,1);
            links = [cell2mat(file{fileIdx}.features.ID1), cell2mat(file{fileIdx}.features.ID2)];
            for node1Idx = 1 : noOfNodes - 1
                for node2Idx = node1Idx + 1 : noOfNodes
                    
                    node1xy = file{fileIdx}.layout{layoutNo}{sampleNo}.xy(node1Idx,:);
                    node2xy = file{fileIdx}.layout{layoutNo}{sampleNo}.xy(node2Idx,:);
                    linkLengthPostLoc = sqrt(sum((node2xy - node1xy).^2));
                    linkNo = (links(:,1) == nodesId(node1Idx) & links(:,2) == nodesId(node2Idx)) | (links(:,1) == nodesId(node2Idx) & links(:,2) == nodesId(node1Idx));
                   
%                     if(strcmp(setSelectionStr,'Train') && (file{fileIdx}.features.set{linkNo}(sampleNo) == options.TRAIN_SET_LABEL_CONSTANT) && (file{fileIdx}.features.set{linkNo}(sampleNo) == options.TRAIN_SET_LABEL_CONSTANT)  && (file{fileIdx}.features.set{linkNo}(sampleNo) == options.TRAIN_SET_LABEL_CONSTANT)) || ...
%                     (( (strcmp(setSelectionStr,'CrossValidation') || strcmp(setSelectionStr,'Test')) && options.MERGE_TEST_AND_CORSSVALIDATION) && (file{fileIdx}.features.set{linkNo}(sampleNo) == options.CROSSVALIDATION_SET_LABEL_CONSTANT) && (file{fileIdx}.features.set{linkNo}(sampleNo) == options.CROSSVALIDATION_SET_LABEL_CONSTANT)  && (file{fileIdx}.features.set{linkNo}(sampleNo) == options.CROSSVALIDATION_SET_LABEL_CONSTANT)) || ...
%                     (( (strcmp(setSelectionStr,'CrossValidation') || strcmp(setSelectionStr,'Test'))  && options.MERGE_TEST_AND_CORSSVALIDATION) && (file{fileIdx}.features.set{linkNo}(sampleNo) == options.TEST_SET_LABEL_CONSTANT) && (file{fileIdx}.features.set{linkNo}(sampleNo) == options.TEST_SET_LABEL_CONSTANT)  && (file{fileIdx}.features.set{linkNo}(sampleNo) == options.TEST_SET_LABEL_CONSTANT)) || ...              
%                     strcmp(setSelectionStr,'All')
                        %TODO: check linkNo size (must contain only one element)
                        linkLengthGroundTruth = file{fileIdx}.features.Y.distance{linkNo}(sampleNo);
                        
                        distanceEstim(linkSampleNo,1) = linkLengthPostLoc;
                        distanceGroundTruth(linkSampleNo,1) = linkLengthGroundTruth;
                        
                        linkSampleNo = linkSampleNo + 1;
%                     end
                end
            end
        end
    end
    
    distanceEstim = distanceEstim(1:linkSampleNo-1,1);
    distanceGroundTruth = distanceGroundTruth(1:linkSampleNo-1,1);
    
    predictionError = distanceEstim-distanceGroundTruth;
    predictionError(isnan(predictionError)) = 0;    
    predictionErrorNorm = predictionError./distanceGroundTruth;
    
%     err.mse = sqrt(1/(size(predictionError,1)*size(predictionError,2))*sum(sum(predictionError.^2)));
%     err.nmse = sqrt(1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(predictionErrorNorm.^2)));
%     err.nmae = 1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(abs(predictionErrorNorm)));
err.rmse = sqrt(1/(size(predictionError,1)*size(predictionError,2))*sum(sum(predictionError.^2)));
err.rnmse = sqrt(1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(predictionErrorNorm.^2)));
err.nmae = 1/(size(predictionErrorNorm,1)*size(predictionErrorNorm,2))*sum(sum(abs(predictionErrorNorm)));

end