function features = divideSets(file,options)
if isfield(file,'groundTruth')
    setPartitionPolicy = options.SETS_PARTITION_POLICY;
    noOfLinks = size(file.links.IDrx,1);
    noOfTimeSamples = size(file.links.windowedSignal.timestamp{1},1);
    noOfNodes = sqrt(noOfLinks);
    noOfBiLink = noOfNodes*(noOfNodes - 1) / 2;
    features = file.features;
    
    set = cell(noOfNodes*(noOfNodes-1)/2 , 1);
    
    for linkNo = 1 : noOfBiLink
        ID1 = file.features.ID1{linkNo};
        ID2 = file.features.ID2{linkNo};
        tempSamplesIdx = 1:1:noOfTimeSamples;
        if setPartitionPolicy == 1
            set{linkNo} = zeros(noOfTimeSamples,1); %initializa variable
            set{linkNo}(randsample(tempSamplesIdx,round(noOfTimeSamples*0.6))) = options.TRAIN_SET_LABEL_CONSTANT;
            
            tempSamplesIdx = find(set{linkNo} ~= options.TRAIN_SET_LABEL_CONSTANT);
            set{linkNo}(randsample(tempSamplesIdx,round(noOfTimeSamples*0.2))) = options.CROSSVALIDATION_SET_LABEL_CONSTANT; %2 = cross validationset
            tempSamplesIdx = find(set{linkNo} ~= options.TRAIN_SET_LABEL_CONSTANT & set{linkNo} ~= options.CROSSVALIDATION_SET_LABEL_CONSTANT);
            
            set{linkNo}(tempSamplesIdx) = options.TEST_SET_LABEL_CONSTANT; %3 = test set
            
            if(find(set{linkNo} == 0,1))
                warning('The random selection has left some samples to zero');
            end
        elseif setPartitionPolicy == 2
            trainingNodesId = options.TRAIN_SET_NODES_ID;
            testNodesId = options.TEST_SET_NODES_ID;
            linksSet = zeros(noOfBiLink,1);
            if sum(trainingNodesId == ID1) && sum(trainingNodesId == ID2) %if both nodes are in trainingNodesId the link is assigned to the training set
                linksSet(linkNo,1) = options.TRAIN_SET_LABEL_CONSTANT;
            end
            if sum(testNodesId == ID1) && sum(testNodesId == ID2)
                linksSet(linkNo,1) = options.TEST_SET_LABEL_CONSTANT;
            end
            set{linkNo} = ones(noOfTimeSamples,1)*linksSet(linkNo,1);
            
            %warning('No validation set when using setPartitionPolicy = 2 (for now)')
        elseif setPartitionPolicy == 3
            if find(options.TRAIN_SET_FILE_IDX == file.fileIdx)
                fileSet = options.TRAIN_SET_LABEL_CONSTANT;
            end
            if find(options.CROSSVALIDATION_SET_FILE_IDX == file.fileIdx)
                fileSet = options.CROSSVALIDATION_SET_LABEL_CONSTANT;
            end
            if find(options.TEST_SET_FILE_IDX == file.fileIdx)
                fileSet = options.TEST_SET_LABEL_CONSTANT;
            end
            set{linkNo} = ones(noOfTimeSamples,1)*fileSet;
        end
    end
    
    features.set = set;
end
