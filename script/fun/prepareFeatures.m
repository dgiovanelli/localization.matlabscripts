function [X, Y, SETS, linksRec, filesRec, triangleRec] = prepareFeatures(files,options)

modelTypeStr = options.INPUT_DATA_TYPE;
x = [];
y = [];
sets = [];
linksRec = [];
filesRec = [];
triangleRec = [];
noOfFiles = size(files,1);

if options.FADE_MODEL_TO_USE == options.POLY_FADE_MODEL_LABEL_CONSTANT || options.FADE_MODEL_TO_USE == options.LOG_FADE_MODEL_LABEL_CONSTANT
    if strcmp(modelTypeStr,options.ONLY_RSSI_DATA)
        
        for fileNo = 1:noOfFiles
            noOfLinks = size(files{fileNo}.features.ID1,1);
            noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
            trainingSetLogicalIdx = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks) == options.TRAIN_SET_LABEL_CONSTANT;
            distance = reshape(cell2mat(files{fileNo}.features.Y.distance),noOfTimeSamples,noOfLinks);
            rssi = reshape(cell2mat(files{fileNo}.features.X.rssi),noOfTimeSamples,noOfLinks);
            set = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks);
            x = [x ; rssi(trainingSetLogicalIdx)];
            y = [y ; distance(trainingSetLogicalIdx)];
            sets = [sets; set];
        end
        
        X = x;
        Y = y;
        SETS = sets;
    elseif strcmp(modelTypeStr,options.RSSI_AND_ORIENTATION_DATA)
        
        for fileNo = 1:noOfFiles
            noOfLinks = size(files{fileNo}.features.ID1,1);
            noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
            %trainingSetLogicalIdx = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks) == options.TRAIN_SET_LABEL_CONSTANT;
            distance = reshape(cell2mat(files{fileNo}.features.Y.distance),noOfTimeSamples,noOfLinks);
            rssi = reshape(cell2mat(files{fileNo}.features.X.rssi),noOfTimeSamples,noOfLinks);
            set = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks);
            node1Orientation = reshape(cell2mat(files{fileNo}.features.X.node1Orientation),noOfTimeSamples,noOfLinks);
            node2Orientation = reshape(cell2mat(files{fileNo}.features.X.node2Orientation),noOfTimeSamples,noOfLinks);
            %         node1AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node1AngleOfLink),noOfTimeSamples,noOfLinks);
            %         node2AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node2AngleOfLink),noOfTimeSamples,noOfLinks);
            %         X = [X ; rssi(trainingSetLogicalIdx) , node1Orientation(trainingSetLogicalIdx), node2Orientation(trainingSetLogicalIdx), node1AngleOfLink(trainingSetLogicalIdx), node2AngleOfLink(trainingSetLogicalIdx)];
            x = [x ; rssi , node1Orientation, node2Orientation];
            y = [y ; distance];
            sets = [sets; set];
        end
        
        X = x;
        Y = y;
        SETS = sets;
    else
        error('modelTypeStr must be onlyRssi or rssiAndOrientation!');
    end
    
elseif options.FADE_MODEL_TO_USE == options.ANN2_MODEL_LABEL_CONSTANT
    
    p = options.POLYNOMIAL_FEATURES_DEGREE;
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
                x = [x ; rssiFeatures]; %, linksAnglesFeature];%,node1OrientationFeatures,node2OrientationFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];%,node1OrientationFeatures,node2OrientationFeatures];
                y = [y ; distanceFeatures];
                sets = [sets ; set];
                linksRec = [linksRec ; link1_2idx*ones(size(rssiFeatures,1),1), link2_3idx*ones(size(rssiFeatures,1),1), link3_1idx*ones(size(rssiFeatures,1),1)];
                filesRec = [filesRec ; fileNo*ones(size(rssiFeatures,1),1)];
                triangleRec = [triangleRec ; triangleIdx*ones(size(rssiFeatures,1),1)];
            end
        end
    end
    X = x;
    Y = y;
    SETS = sets;
end