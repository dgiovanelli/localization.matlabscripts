function files = estimateLayout(files,model,options,layoutNo) %layoutNo is the reference to start with for calculating the link angles! Leave it empty or set to 0 for simply do the layout

if size(files,1) ~= 1
    warning('It is not tested to call estimateLayout(_) with multiple files');
end

if ~exist('layoutNo','var')
    layoutNo = 0;
end
X = [];
y = [];
fileOfEstim = [];
linksRec = [];
totalAmoutOfSamples = 0;
orientationRec = [];
orientation = [];
setSelectionStr = 'All';
noOfFiles = size(files,1);
iiii = 0;

if model.fadeModelType == options.POLY_FADE_MODEL_LABEL_CONSTANT || model.fadeModelType == options.LOG_FADE_MODEL_LABEL_CONSTANT
    totalNoOfSamples = 0;
    for fileNo = 1:noOfFiles
        %prepare variables
        if fileNo == 1
            noOfLinks = size(files{fileNo}.features.ID1,1);
        else
            if noOfLinks ~= size(files{fileNo}.features.ID1,1);
                error('If multiple files are passed to estimateLayout(__) they must have the same amount of links!');
            else
                noOfLinks = size(files{fileNo}.features.ID1,1);
            end
        end
        noOfSamples = size(files{fileNo}.features.X.rssi{1},1);
        totalNoOfSamples = totalNoOfSamples + noOfSamples;
        if isfield(files{fileNo}.features,'Y')        
            distance = reshape(cell2mat(files{fileNo}.features.Y.distance),noOfSamples,noOfLinks);
        end
        rssi = reshape(cell2mat(files{fileNo}.features.X.rssi),noOfSamples,noOfLinks);
        totalAmoutOfSamples = totalAmoutOfSamples + size(rssi,1)*size(rssi,2);
        availableIds = unique([cell2mat(files{fileNo}.features.ID1) ; cell2mat(files{fileNo}.features.ID2)]);
        noOfNodes = size(availableIds,1);
        
        %TODO: handle sets somehow
        %get training set indexes
        setsMatrix = 5*ones(noOfSamples,noOfLinks);%reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks);
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
            node1Orientation = reshape(cell2mat(files{fileNo}.features.X.node1Orientation),noOfSamples,noOfLinks);
            node2Orientation = reshape(cell2mat(files{fileNo}.features.X.node2Orientation),noOfSamples,noOfLinks);
            %orientationFeatures = [files{fileNo}.features.X.node1Orientation{link1_2idx}, files{fileNo}.features.X.node2Orientation{link1_2idx}, files{fileNo}.features.X.node1Orientation{link2_3idx}, files{fileNo}.features.X.node2Orientation{link2_3idx}, files{fileNo}.features.X.node1Orientation{link3_1idx}, files{fileNo}.features.X.node2Orientation{link3_1idx}];
            
            X = [X ; rssi(trainingSetLogicalIdx) , node1Orientation(trainingSetLogicalIdx), node2Orientation(trainingSetLogicalIdx)];
            fileOfEstim = [fileOfEstim; fileNo*ones(size(rssi(trainingSetLogicalIdx)))];
            %             node1AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node1AngleOfLink),noOfTimeSamples,noOfLinks);
            %             node2AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node2AngleOfLink),noOfTimeSamples,noOfLinks);
            %             Xtrain = [Xtrain ; rssi(trainingSetLogicalIdx) , node1Orientation(trainingSetLogicalIdx), node2Orientation(trainingSetLogicalIdx), node1AngleOfLink(trainingSetLogicalIdx) ,node2AngleOfLink(trainingSetLogicalIdx)];
        elseif strcmp(model.inputDataType,options.ONLY_RSSI_DATA)
            X = [X ; rssi(trainingSetLogicalIdx)];
            %linksRec = [linksRec ; idivide(int32(find(trainingSetLogicalIdx)-1),int32(noOfTimeSamples))+1 ];
        elseif strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
            alpha = 1;
            
            %initialize angles
            if layoutNo == 0
                files{fileNo}.features.X.node1AngleOfLink = cell(noOfLinks,1);%{link1_2idx,1}
                files{fileNo}.features.X.node2AngleOfLink = cell(noOfLinks,1);%{link1_2idx,1}
                for linkNo=1:noOfLinks
                    if 1 %%randomply initialize angles!
                        files{fileNo}.features.X.node1AngleOfLink{linkNo,1} = 2*pi*ones(noOfSamples,1)*rand(1);
                        files{fileNo}.features.X.node2AngleOfLink{linkNo,1} = 2*pi*ones(noOfSamples,1)*rand(1);
                    else %%initialize angles using groundtruth
                        files{fileNo}.features.X.node1AngleOfLink{linkNo,1} = files{fileNo}.features.Y.node1AngleOfLink{linkNo};%2*pi*rand(noOfSamples,1);
                        files{fileNo}.features.X.node2AngleOfLink{linkNo,1} = files{fileNo}.features.Y.node2AngleOfLink{linkNo};%2*pi*rand(noOfSamples,1);
                    end
                end
            end
            %             node1AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node1AngleOfLink),noOfSamples,noOfLinks);
            %             node2AngleOfLink = reshape(cell2mat(files{fileNo}.features.Y.node2AngleOfLink),noOfSamples,noOfLinks);
            linksAngleNode1 = [];
            linksAngleNode2 = [];
            for linkIdx = 1:noOfLinks
                if layoutNo ~= 0
                    [linkLayoutAngleNode1, linkLayoutAngleNode2] = calculateLayoutLinkAngles(files{fileNo}.layout{layoutNo}, files{fileNo}.features.ID1{linkIdx}, files{fileNo}.features.ID2{linkIdx}, options); %calculate this angle using layout
                else
                    %if isfield(files{fileNo}.features,'Y')
                    linkLayoutAngleNode1 =  files{fileNo}.features.X.node1AngleOfLink{linkNo,1}; %these have been previously initialized (randomly)
                    linkLayoutAngleNode2 =  files{fileNo}.features.X.node2AngleOfLink{linkNo,1};
                    %end
                end
                
                if isfield(files{fileNo}.features.X,'node1AngleOfLink') && ~isempty(files{fileNo}.features.X.node1AngleOfLink{linkIdx,1})
                    linkAngleNode1Diff = linkLayoutAngleNode1 - files{fileNo}.features.X.node1AngleOfLink{linkIdx,1};
                    linkAngleNode2Diff = linkLayoutAngleNode2 - files{fileNo}.features.X.node2AngleOfLink{linkIdx,1};
                    linkAngleNode1 = files{fileNo}.features.X.node1AngleOfLink{linkIdx,1} + linkAngleNode1Diff * alpha;
                    linkAngleNode2 = files{fileNo}.features.X.node2AngleOfLink{linkIdx,1} + linkAngleNode2Diff * alpha;
                else
                    linkAngleNode1Diff = linkLayoutAngleNode1;
                    linkAngleNode2Diff = linkLayoutAngleNode2;
                    warning('No layout angle estimation is provided for this layout. alpha will be set to 1!');
                    alpha = 1;
                    linkAngleNode1 = linkAngleNode1Diff * alpha;
                    linkAngleNode2 = linkAngleNode2Diff * alpha;
                    if ~isfield(files{fileNo}.features.X,'node1AngleOfLink')
                        files{fileNo}.features.X.node1AngleOfLink = cell(noOfLinks,1);
                        files{fileNo}.features.X.node2AngleOfLink = cell(noOfLinks,1);
                    end
                end
                if linkIdx == 1 || abs(max(abs(mod(linkAngleNode1Diff,2*pi)-pi)-pi)*options.RAD_TO_DEF_CONST) > maxAngleDiffDeg(1,1)
                    maxAngleDiffDeg = abs(max(abs(mod(linkAngleNode1Diff,2*pi)-pi)-pi)*options.RAD_TO_DEF_CONST);
                end
                if abs(max(abs(mod(linkAngleNode2Diff,2*pi)-pi)-pi)*options.RAD_TO_DEF_CONST) > abs(maxAngleDiffDeg(1,1))
                    maxAngleDiffDeg = abs(max(abs(mod(linkAngleNode2Diff,2*pi)-pi)-pi)*options.RAD_TO_DEF_CONST);
                end
                
                linksAngleNode1 = [linksAngleNode1, linkAngleNode1];
                linksAngleNode2 = [linksAngleNode2, linkAngleNode2];
                
                files{fileNo}.features.X.node1AngleOfLink{linkIdx,1} = linkAngleNode1;
                files{fileNo}.features.X.node2AngleOfLink{linkIdx,1} = linkAngleNode2;
%                 if linkIdx == 1 && files{fileNo}.fileIdx == 1
%                     fprintf('Old link angle node 1 = %.2f - Old link angle node 2 = %.2f\n',linkLayoutAngleNode1(1)*options.RAD_TO_DEF_CONST, linkLayoutAngleNode2(1)*options.RAD_TO_DEF_CONST);
%                     fprintf('Link angle node 1 update = %.2f - Link angle node 2 update = %.2f\n',linkAngleNode1Diff(1)*options.RAD_TO_DEF_CONST, linkAngleNode2Diff(1)*options.RAD_TO_DEF_CONST);
%                     fprintf('New link angle node 1 = %.2f - new link angle node 1 = %.2f\n\n',linkAngleNode1(1)*options.RAD_TO_DEF_CONST, linkAngleNode1(1)*options.RAD_TO_DEF_CONST);
%                 end
            end
            figure(55654)
            hold on
            plot(layoutNo,maxAngleDiffDeg,'o','lineWidth',3);
            grid on;
            xlabel('Iteration');
            ylabel('Max angle diff [deg]');
%            fprintf('Maximum difference between angles: %.2f\n',maxAngleDiffDeg);
%             linksAngleNode1Update = zeros(size(linksAngleNode1Diff));
%             linksAngleNode2Update = zeros(size(linksAngleNode2Diff));
%             
%             linksAngleNode1Diff = double(mod(linksAngleNode1Diff,2*pi));
%             linksAngleNode1Diff = (floor(linksAngleNode1Diff*1000000))/1000000; %use floor to avoid to overcome 2pi
%             linksAngleNode2Diff = double(mod(linksAngleNode2Diff,2*pi));
%             linksAngleNode2Diff = (floor(linksAngleNode2Diff*1000000))/1000000; %use floor to avoid to overcome 2pi
%             
%             
%             for nodeIdx = 1:size(availableIds,1)
%                 linkIdxsN1 = find(cell2mat(files{fileNo}.features.ID1) == availableIds(nodeIdx));
%                 linkIdxsN2 = find(cell2mat(files{fileNo}.features.ID2) == availableIds(nodeIdx));
%                 
%                 toAverage = size(linkIdxsN1,1) + size(linkIdxsN2,1);
%                 
%                 
%                 
%                 %linksAngleNode1Update = 
%                 
%                 linkAngleNode1 = files{fileNo}.features.X.node1AngleOfLink{linkIdx,1} + linkAngleNode1Diff;
%                 linkAngleNode2 = files{fileNo}.features.X.node2AngleOfLink{linkIdx,1} + linkAngleNode2Diff;
%                 
%                 linksAngleNode1 = [linksAngleNode1, linkAngleNode1];
%                 linksAngleNode2 = [linksAngleNode2, linkAngleNode2];
%                 
%                 files{fileNo}.features.X.node1AngleOfLink{linkIdx,1} = linkAngleNode1;
%                 files{fileNo}.features.X.node2AngleOfLink{linkIdx,1} = linkAngleNode2;
%             end
            
            node1Orientation = reshape(cell2mat(files{fileNo}.features.X.node1Orientation),noOfSamples,noOfLinks);
            node2Orientation = reshape(cell2mat(files{fileNo}.features.X.node2Orientation),noOfSamples,noOfLinks);
            
            linksAngleNode1 = double(mod(linksAngleNode1,2*pi));
            linksAngleNode1 = (floor(linksAngleNode1*1000000))/1000000; %use floor to avoid to overcome 2pi
            linksAngleNode2 = double(mod(linksAngleNode2,2*pi));
            linksAngleNode2 = (floor(linksAngleNode2*1000000))/1000000; %use floor to avoid to overcome 2pi
            
            X = [X ; rssi(trainingSetLogicalIdx), linksAngleNode1(trainingSetLogicalIdx), linksAngleNode2(trainingSetLogicalIdx)];
        end
        
        %if(strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA))
            for nodeIdx = 1:noOfNodes
                linkIdx = find(cell2mat(files{fileNo}.features.ID1) == availableIds(nodeIdx));
                if isempty(linkIdx)
                    linkIdx = find(cell2mat(files{fileNo}.features.ID2) == availableIds(nodeIdx));
                    linkIdx = linkIdx(1);
                    orientation = [orientation , files{fileNo}.features.X.node2Orientation{linkIdx}];
                else
                    linkIdx = linkIdx(1);
                    orientation = [orientation , files{fileNo}.features.X.node1Orientation{linkIdx}];
                end
            end
            
        %end
        if isfield(files{fileNo}.features,'Y')
            y = [y ; distance(trainingSetLogicalIdx)];
        end
        fileOfEstim = [fileOfEstim; fileNo*ones( noOfSamples,1 )];
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
    
    distanceEstim = reshape(yPredicted,totalNoOfSamples,noOfLinks);
    
elseif model.fadeModelType == options.POLY2_MODEL_LABEL_CONSTANT
    %     for fileNo = 1:noOfFiles
    %         %prepare variables
    %         noOfLinks = size(files{fileNo}.features.ID1,1);
    %         noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
    %
    %         nodeIdUnderFocus = 33;
    %         %this reorganizes the links order to be always the same
    %         newLinkIdx = 1;
    %         availableIds = unique([cell2mat(files{fileNo}.features.ID1) ; cell2mat(files{fileNo}.features.ID2)]);
    %         noOfNodes = size(availableIds,1);
    %         startingLinkIdxs = find(nodeIdUnderFocus == availableIds);
    %         for node1Idx = 1: noOfNodes-1
    %             for node2Idx = node1Idx+1: noOfNodes
    %                 node1ActIdx = mod(node1Idx+startingLinkIdxs-2,noOfNodes)+1;
    %                 node2ActIdx = mod(node2Idx+startingLinkIdxs-2,noOfNodes)+1;
    %                 ID1Act = availableIds(node1ActIdx);
    %                 ID2Act = availableIds(node2ActIdx);
    %
    %                 actLinkIdx = find( (cell2mat(files{fileNo}.features.ID1) == ID1Act & cell2mat(files{fileNo}.features.ID2) == ID2Act) | (cell2mat(files{fileNo}.features.ID1) == ID2Act & cell2mat(files{fileNo}.features.ID2) == ID1Act ));
    %
    %                 newFeatures = files{fileNo}.features;
    %                 newFeatures.ID1{newLinkIdx} = files{fileNo}.features.ID1{actLinkIdx};
    %                 newFeatures.ID2{newLinkIdx} = files{fileNo}.features.ID2{actLinkIdx};
    %                 newFeatures.set{newLinkIdx} = files{fileNo}.features.set{actLinkIdx};
    %                 newFeatures.X.rssi{newLinkIdx} = files{fileNo}.features.X.rssi{actLinkIdx};
    %                 newFeatures.X.node1Orientation{newLinkIdx} = files{fileNo}.features.X.node1Orientation{actLinkIdx};
    %                 newFeatures.X.node2Orientation{newLinkIdx} = files{fileNo}.features.X.node2Orientation{actLinkIdx};
    %                 newFeatures.X.rssiStd{newLinkIdx} = files{fileNo}.features.X.rssiStd{actLinkIdx};
    %                 newFeatures.X.rssiMean{newLinkIdx} = files{fileNo}.features.X.rssiMean{actLinkIdx};
    %                 newFeatures.Y.distance{newLinkIdx} = files{fileNo}.features.Y.distance{actLinkIdx};
    %                 newFeatures.Y.node1AngleOfLink{newLinkIdx} = files{fileNo}.features.Y.node1AngleOfLink{actLinkIdx};
    %                 newFeatures.Y.node2AngleOfLink{newLinkIdx} = files{fileNo}.features.Y.node2AngleOfLink{actLinkIdx};
    %
    %                 newLinkIdx = newLinkIdx+1;
    %             end
    %         end
    %
    %         %get training set indexes
    %         setsMatrix = 5*ones(noOfTimeSamples,noOfLinks);%setsMatrix = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks);
    %         if strcmp(setSelectionStr,'Train')
    %             trainingSetLogicalIdx = setsMatrix == options.TRAIN_SET_LABEL_CONSTANT;
    %         elseif strcmp(setSelectionStr,'All')
    %             trainingSetLogicalIdx = setsMatrix ~= 0;
    %         else
    %             if options.MERGE_TEST_AND_CORSSVALIDATION
    %
    %                 trainingSetLogicalIdx = (setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT) | (setsMatrix == options.TEST_SET_LABEL_CONSTANT) ;
    %             else
    %                 if strcmp(setSelectionStr,'CrossValidation')
    %                     trainingSetLogicalIdx = setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT;
    %                 elseif strcmp(setSelectionStr,'Test')
    %                     trainingSetLogicalIdx = setsMatrix == options.TEST_SET_LABEL_CONSTANT;
    %                 else
    %                     error('invalid setSelectionStr');
    %                 end
    %             end
    %         end
    %
    %         distance = reshape(cell2mat(newFeatures.Y.distance),noOfTimeSamples,noOfLinks);
    %         rssi = reshape(cell2mat(newFeatures.X.rssi),noOfTimeSamples,noOfLinks);
    %         node1Orientation = reshape(cell2mat(newFeatures.X.node1Orientation),noOfTimeSamples,noOfLinks);
    %         node2Orientation = reshape(cell2mat(newFeatures.X.node2Orientation),noOfTimeSamples,noOfLinks);
    %         node1AngleOfLink = reshape(cell2mat(newFeatures.Y.node1AngleOfLink),noOfTimeSamples,noOfLinks);
    %         node2AngleOfLink = reshape(cell2mat(newFeatures.Y.node2AngleOfLink),noOfTimeSamples,noOfLinks);
    %
    %         validLinksLogicalIdxX = ones(1,size(newFeatures.ID1,1));%(cell2mat(newFeatures.ID1) == nodeIdUnderFocus | cell2mat(newFeatures.ID2) == nodeIdUnderFocus)';% ones(1,size(newFeatures.ID1,1));
    %         trainingSetLogicalIdxSelectedLinksX = trainingSetLogicalIdx(:,find(validLinksLogicalIdxX));
    %         rssiSelectedLinks = rssi(:,find(validLinksLogicalIdxX));
    %         node1OrientationSelectedLinks = node1Orientation(:,find(validLinksLogicalIdxX));
    %         node2OrientationSelectedLinks = node2Orientation(:,find(validLinksLogicalIdxX));
    %         node1AngleOfLinkSelectedLinks = node1AngleOfLink(:,find(validLinksLogicalIdxX));
    %         node2AngleOfLinkSelectedLinks = node2AngleOfLink(:,find(validLinksLogicalIdxX));
    %         validLinksLogicalIdxY = (cell2mat(newFeatures.ID1) == nodeIdUnderFocus | cell2mat(newFeatures.ID2) == nodeIdUnderFocus)';% ones(1,size(newFeatures.ID1,1));
    %         trainingSetLogicalIdxSelectedLinksY = trainingSetLogicalIdx(:,find(validLinksLogicalIdxY));
    %         distanceSelectedLinks = distance(:,find(validLinksLogicalIdxY));
    %
    %         temp = rssiSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
    %         rssiFeatures = reshape(temp,size(temp,1)/size(rssiSelectedLinks,2),size(rssiSelectedLinks,2));
    %         temp = distanceSelectedLinks(trainingSetLogicalIdxSelectedLinksY);
    %         distanceFeatures = reshape(temp,size(temp,1)/size(distanceSelectedLinks,2),size(distanceSelectedLinks,2));
    %         temp = node1OrientationSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
    %         node1OrientationFeatures = reshape(temp,size(temp,1)/size(node1OrientationSelectedLinks,2),size(node1OrientationSelectedLinks,2));
    %         temp = node2OrientationSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
    %         node2OrientationFeatures = reshape(temp,size(temp,1)/size(node2OrientationSelectedLinks,2),size(node2OrientationSelectedLinks,2));
    %         temp = node1AngleOfLinkSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
    %         node1AngleOfLinkFeatures = reshape(temp,size(temp,1)/size(node1AngleOfLinkSelectedLinks,2),size(node1AngleOfLinkSelectedLinks,2));
    %         temp = node2AngleOfLinkSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
    %         node2AngleOfLinkFeatures = reshape(temp,size(temp,1)/size(node2AngleOfLinkSelectedLinks,2),size(node2AngleOfLinkSelectedLinks,2));
    %
    %         %        X = [X ; rssiFetures,node1OrientationFeatures,node2OrientationFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];
    %         X = [X ; rssiFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];%,node1OrientationFeatures,node2OrientationFeatures];
    %         y = [y ; distanceFeatures];
    %     end
    %
    %     p=model.p;
    %     %Xpower = calculatePowerFeatures(Xtrain);
    %     XPoly = calculatePolynomialFeatures(X, p);
    %
    %     [XNorm, ~, ~] = featureNormalize(XPoly,model);
    %
    %     XNorm = [ones(size(XPoly,1),1), XNorm];
    %
    %     yPredicted = fadeHypothesis(XNorm,model.tetha,options);
    %
    
    error('Using this model for calculating the layout is not supported!');
    
    
elseif model.fadeModelType == options.ANN_MODEL_LABEL_CONSTANT
    
    
    %     for fileNo = 1:noOfFiles
    %
    %         %for linkIdx = 1:noOfLinks
    %         availableIds = unique([cell2mat(files{fileNo}.features.ID1) ; cell2mat(files{fileNo}.features.ID2)]);
    %         noOfNodes = size(availableIds,1);
    %         noOfLinks = noOfNodes*(noOfNodes-1)/2;
    %         for nodeIdUnderFocusIdx = 1:noOfNodes
    %             %this reorganizes the links order to be always the same
    %             newLinkIdx = 1;
    %             %newFeatures = files{fileNo}.features;
    %             nodeIdUnderFocus = availableIds(nodeIdUnderFocusIdx);
    %             nodeIdUnderFocus_2 = nodeIdUnderFocus;
    %             startingLinkIdxs = find(nodeIdUnderFocus == availableIds);
    %
    %             validLinkIdx = find( (cell2mat(files{fileNo}.features.ID1) == nodeIdUnderFocus | cell2mat(files{fileNo}.features.ID2) == nodeIdUnderFocus) );
    %             idx = 0;
    %
    %             for linkNo = 1:noOfLinks
    %                 if linkNo >= size(validLinkIdx,1)
    %                     idx = idx + 1;
    %                     nodeIdUnderFocus_2 = newFeatures.ID2{idx};
    %                     validLinkIdx = [validLinkIdx; find( (cell2mat(files{fileNo}.features.ID1) == nodeIdUnderFocus_2 | cell2mat(files{fileNo}.features.ID2) == nodeIdUnderFocus_2) )];
    %                     validLinkIdx = unique(validLinkIdx,'stable');
    %                 end
    %                 isFlipped = files{fileNo}.features.ID2{validLinkIdx(linkNo)} == nodeIdUnderFocus_2;
    %                 if(isFlipped)
    %                     newFeatures.ID1{linkNo,1} = files{fileNo}.features.ID2{validLinkIdx(linkNo)};
    %                     newFeatures.ID2{linkNo,1} = files{fileNo}.features.ID1{validLinkIdx(linkNo)};
    %                 else
    %                     newFeatures.ID1{linkNo,1} = files{fileNo}.features.ID1{validLinkIdx(linkNo)};
    %                     newFeatures.ID2{linkNo,1} = files{fileNo}.features.ID2{validLinkIdx(linkNo)};
    %                 end
    %                 newFeatures.set{linkNo,1} = files{fileNo}.features.set{validLinkIdx(linkNo)};
    %                 newFeatures.X.rssi{linkNo,1} = files{fileNo}.features.X.rssi{validLinkIdx(linkNo)};
    %                 newFeatures.X.node1Orientation{linkNo,1} = files{fileNo}.features.X.node1Orientation{validLinkIdx(linkNo)};
    %                 newFeatures.X.node2Orientation{linkNo,1} = files{fileNo}.features.X.node2Orientation{validLinkIdx(linkNo)};
    %                 newFeatures.X.rssiStd{linkNo,1} = files{fileNo}.features.X.rssiStd{validLinkIdx(linkNo)};
    %                 newFeatures.X.rssiMean{linkNo,1} = files{fileNo}.features.X.rssiMean{validLinkIdx(linkNo)};
    %                 newFeatures.Y.distance{linkNo,1} = files{fileNo}.features.Y.distance{validLinkIdx(linkNo)};
    %                 newFeatures.Y.node1AngleOfLink{linkNo,1} = files{fileNo}.features.Y.node1AngleOfLink{validLinkIdx(linkNo)};
    %                 newFeatures.Y.node2AngleOfLink{linkNo,1} = files{fileNo}.features.Y.node2AngleOfLink{validLinkIdx(linkNo)};
    %             end
    %             newLinks = [cell2mat(newFeatures.ID1) , cell2mat(newFeatures.ID2)];
    %             originalLinks = [(cell2mat(files{fileNo}.features.ID1)),(cell2mat(files{fileNo}.features.ID2))];
    %             %end
    %             noOfTimeSamples = size(files{fileNo}.features.X.rssi{1},1);
    %             noOfLinks = size(files{fileNo}.features.ID1,1);
    %
    %             %get training set indexes
    %             setsMatrix = 5*ones(noOfTimeSamples,noOfLinks);%setsMatrix = reshape(cell2mat(files{fileNo}.features.set),noOfTimeSamples,noOfLinks);
    %             if strcmp(setSelectionStr,'Train')
    %                 trainingSetLogicalIdx = setsMatrix == options.TRAIN_SET_LABEL_CONSTANT;
    %             elseif strcmp(setSelectionStr,'All')
    %                 trainingSetLogicalIdx = setsMatrix ~= 0;
    %             else
    %                 if options.MERGE_TEST_AND_CORSSVALIDATION
    %
    %                     trainingSetLogicalIdx = (setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT) | (setsMatrix == options.TEST_SET_LABEL_CONSTANT) ;
    %                 else
    %                     if strcmp(setSelectionStr,'CrossValidation')
    %                         trainingSetLogicalIdx = setsMatrix == options.CROSSVALIDATION_SET_LABEL_CONSTANT;
    %                     elseif strcmp(setSelectionStr,'Test')
    %                         trainingSetLogicalIdx = setsMatrix == options.TEST_SET_LABEL_CONSTANT;
    %                     else
    %                         error('invalid setSelectionStr');
    %                     end
    %                 end
    %             end
    %
    %             %trainingSetLogicalIdx = reshape(cell2mat(newFeatures.set),noOfTimeSamples,noOfLinks) ~= 0; %the nn toolbox automatically split in three training sets
    %             distance = reshape(cell2mat(newFeatures.Y.distance),noOfTimeSamples,noOfLinks);
    %             rssi = reshape(cell2mat(newFeatures.X.rssi),noOfTimeSamples,noOfLinks);
    %             node1Orientation = reshape(cell2mat(newFeatures.X.node1Orientation),noOfTimeSamples,noOfLinks);
    %             node2Orientation = reshape(cell2mat(newFeatures.X.node2Orientation),noOfTimeSamples,noOfLinks);
    %             node1AngleOfLink = reshape(cell2mat(newFeatures.Y.node1AngleOfLink),noOfTimeSamples,noOfLinks);
    %             node2AngleOfLink = reshape(cell2mat(newFeatures.Y.node2AngleOfLink),noOfTimeSamples,noOfLinks);
    %
    %             validLinksLogicalIdxX = (cell2mat(newFeatures.ID1) == nodeIdUnderFocus | cell2mat(newFeatures.ID2) == nodeIdUnderFocus)';% ones(1,size(newFeatures.ID1,1));;%ones(1,size(newFeatures.ID1,1));%(cell2mat(newFeatures.ID1) == nodeIdUnderFocus | cell2mat(newFeatures.ID2) == nodeIdUnderFocus)';% ones(1,size(newFeatures.ID1,1));
    %             trainingSetLogicalIdxSelectedLinksX = trainingSetLogicalIdx(:,find(validLinksLogicalIdxX));
    %             rssiSelectedLinks = rssi(:,find(validLinksLogicalIdxX));
    %             node1OrientationSelectedLinks = node1Orientation(:,find(validLinksLogicalIdxX));
    %             node2OrientationSelectedLinks = node2Orientation(:,find(validLinksLogicalIdxX));
    %             node1AngleOfLinkSelectedLinks = node1AngleOfLink(:,find(validLinksLogicalIdxX));
    %             node2AngleOfLinkSelectedLinks = node2AngleOfLink(:,find(validLinksLogicalIdxX));
    %             validLinksLogicalIdxY = (cell2mat(newFeatures.ID1) == nodeIdUnderFocus | cell2mat(newFeatures.ID2) == nodeIdUnderFocus)';% ones(1,size(newFeatures.ID1,1));
    %             trainingSetLogicalIdxSelectedLinksY = trainingSetLogicalIdx(:,find(validLinksLogicalIdxY));
    %             distanceSelectedLinks = distance(:,find(validLinksLogicalIdxY));
    %
    %             temp = rssiSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
    %             rssiFeatures = reshape(temp,size(temp,1)/size(rssiSelectedLinks,2),size(rssiSelectedLinks,2));
    %             temp = distanceSelectedLinks(trainingSetLogicalIdxSelectedLinksY);
    %             distanceFeatures = reshape(temp,size(temp,1)/size(distanceSelectedLinks,2),size(distanceSelectedLinks,2));
    %             temp = node1OrientationSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
    %             node1OrientationFeatures = reshape(temp,size(temp,1)/size(node1OrientationSelectedLinks,2),size(node1OrientationSelectedLinks,2));
    %             temp = node2OrientationSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
    %             node2OrientationFeatures = reshape(temp,size(temp,1)/size(node2OrientationSelectedLinks,2),size(node2OrientationSelectedLinks,2));
    %             temp = node1AngleOfLinkSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
    %             node1AngleOfLinkFeatures = reshape(temp,size(temp,1)/size(node1AngleOfLinkSelectedLinks,2),size(node1AngleOfLinkSelectedLinks,2));
    %             temp = node2AngleOfLinkSelectedLinks(trainingSetLogicalIdxSelectedLinksX);
    %             node2AngleOfLinkFeatures = reshape(temp,size(temp,1)/size(node2AngleOfLinkSelectedLinks,2),size(node2AngleOfLinkSelectedLinks,2));
    %
    %             if ~isempty(distanceFeatures)
    %                 %        X = [X ; rssiFetures,node1OrientationFeatures,node2OrientationFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];
    %                 X = [X ; rssiFeatures];%,node1OrientationFeatures,node2OrientationFeatures,node1AngleOfLinkFeatures,node2AngleOfLinkFeatures];%,node1OrientationFeatures,node2OrientationFeatures];
    %                 y = [y ; distanceFeatures];
    %             end
    %         end
    %     end
    %
    %     p=model.p;
    %     %Xpower = calculatePowerFeatures(Xtrain);
    %     XPoly = calculatePolynomialFeatures(X, p);
    %
    %     %[XNorm, ~, ~] = featureNormalize(XPoly,model);
    %     XNorm = XPoly;
    %     %XNorm = [ones(size(XPoly,1),1), XNorm];
    %
    %     yPredicted = sim(model.net,XNorm')';
    error('Using this model for calculating the layout is not supported!');
    
elseif model.fadeModelType == options.ANN2_MODEL_LABEL_CONSTANT
    
    
    p = options.POLYNOMIAL_FEATURES_DEGREE;
    X = [];
    y = [];
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
        noOfSamples = size(files{fileNo}.features.X.rssi{1},1);
        alpha = 1;
        
        %randomply initialize angles if needed!
        if strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
            if layoutNo == 0
                files{fileNo}.features.X.node1AngleOfLink = cell(noOfLinks,1);%{link1_2idx,1}
                files{fileNo}.features.X.node2AngleOfLink = cell(noOfLinks,1);%{link1_2idx,1}
                for linkNo=1:noOfLinks
                    if 1 %randomply initialize angles!
                        files{fileNo}.features.X.node1AngleOfLink{linkNo,1} = 2*pi*ones(noOfSamples,1)*rand(1);
                        files{fileNo}.features.X.node2AngleOfLink{linkNo,1} = 2*pi*ones(noOfSamples,1)*rand(1);
                    else%initialize angles using ground truth
                        files{fileNo}.features.X.node1AngleOfLink{linkNo,1} = files{fileNo}.features.Y.node1AngleOfLink{linkNo};%2*pi*rand(noOfSamples,1);
                        files{fileNo}.features.X.node2AngleOfLink{linkNo,1} = files{fileNo}.features.Y.node2AngleOfLink{linkNo};%2*pi*rand(noOfSamples,1);
                    end
                end
            end
        end
        
        if ~isfield(files{fileNo}.features.X,'node1AngleOfLink') && strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
            files{fileNo}.features.X.node1AngleOfLink = cell(noOfLinks,1);
        end
        if ~isfield(files{fileNo}.features.X,'node2AngleOfLink') && strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
            files{fileNo}.features.X.node2AngleOfLink = cell(noOfLinks,1);
        end
        
        for triangleIdx = 1:size(triangles,1)
            
            node1ID = triangles(triangleIdx,1);
            node2ID = triangles(triangleIdx,2);
            node3ID = triangles(triangleIdx,3);
            
            link1_2idx = find(cell2mat(files{fileNo}.features.ID1) == node1ID & cell2mat(files{fileNo}.features.ID2) == node2ID);
            if isempty(link1_2idx)  %if it's empty the order of nodes is reversed, just search the correct link inverting the order
                link1_2idx = find(cell2mat(files{fileNo}.features.ID1) == node2ID & cell2mat(files{fileNo}.features.ID2) == node1ID);
                if strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
                    if layoutNo ~= 0
                        [link1_2LayoutAngleNode1, link1_2LayoutAngleNode2] = calculateLayoutLinkAngles(files{fileNo}.layout{layoutNo}, node2ID, node1ID, options); %calculate this angle using layout
                    else
                        %if isfield(files{fileNo}.features,'Y')
                        link1_2LayoutAngleNode1 = files{fileNo}.features.X.node2AngleOfLink{link1_2idx};
                        link1_2LayoutAngleNode2 = files{fileNo}.features.X.node1AngleOfLink{link1_2idx};
                        %end
                    end
                    
                    if isfield(files{fileNo}.features.X,'node1AngleOfLink') && ~isempty(files{fileNo}.features.X.node1AngleOfLink{link1_2idx,1}) && layoutNo > 2
                        link1_2AngleNode1Diff = link1_2LayoutAngleNode1 - files{fileNo}.features.X.node2AngleOfLink{link1_2idx,1};
                        link1_2AngleNode2Diff = link1_2LayoutAngleNode2 - files{fileNo}.features.X.node1AngleOfLink{link1_2idx,1};
                        
                        link1_2AngleNode1 = files{fileNo}.features.X.node2AngleOfLink{link1_2idx,1} + alpha*link1_2AngleNode1Diff;
                        link1_2AngleNode2 = files{fileNo}.features.X.node1AngleOfLink{link1_2idx,1} + alpha*link1_2AngleNode2Diff;
                    else
                        %maybe it is the case of declaring files{fileNo}.features.X.node2AngleOfLink
                        link1_2AngleNode1 = link1_2LayoutAngleNode1; %%alpha*link1_2AngleNode1Diff;
                        link1_2AngleNode2 = link1_2LayoutAngleNode2; %%alpha*link1_2AngleNode2Diff;
                    end
                    
                    files{fileNo}.features.X.node2AngleOfLink{link1_2idx,1} = link1_2AngleNode1;
                    files{fileNo}.features.X.node1AngleOfLink{link1_2idx,1} = link1_2AngleNode2;
                end
            else
                if strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
                    if layoutNo ~= 0
                        [link1_2LayoutAngleNode1, link1_2LayoutAngleNode2] = calculateLayoutLinkAngles(files{fileNo}.layout{layoutNo}, node1ID, node2ID, options); %calculate this angle using layout
                    else
                        %if isfield(files{fileNo}.features,'Y')
                        link1_2LayoutAngleNode1 = files{fileNo}.features.X.node1AngleOfLink{link1_2idx};
                        link1_2LayoutAngleNode2 = files{fileNo}.features.X.node2AngleOfLink{link1_2idx};
                        %end
                    end
                    
                    if isfield(files{fileNo}.features.X,'node1AngleOfLink') && ~isempty(files{fileNo}.features.X.node1AngleOfLink{link1_2idx,1}) && layoutNo > 2
                        link1_2AngleNode1Diff = link1_2LayoutAngleNode1 - files{fileNo}.features.X.node1AngleOfLink{link1_2idx,1};
                        link1_2AngleNode2Diff = link1_2LayoutAngleNode2 - files{fileNo}.features.X.node2AngleOfLink{link1_2idx,1};
                        
                        link1_2AngleNode1 = files{fileNo}.features.X.node1AngleOfLink{link1_2idx,1} + alpha*link1_2AngleNode1Diff;
                        link1_2AngleNode2 = files{fileNo}.features.X.node2AngleOfLink{link1_2idx,1} + alpha*link1_2AngleNode2Diff;
                    else
                        link1_2AngleNode1 = link1_2LayoutAngleNode1;
                        link1_2AngleNode2 = link1_2LayoutAngleNode2;
                    end
                    
                    files{fileNo}.features.X.node1AngleOfLink{link1_2idx,1} = link1_2AngleNode1;
                    files{fileNo}.features.X.node2AngleOfLink{link1_2idx,1} = link1_2AngleNode2;
                end
            end
            
            link2_3idx = find(cell2mat(files{fileNo}.features.ID1) == node2ID & cell2mat(files{fileNo}.features.ID2) == node3ID);
            if isempty(link2_3idx)  %if it's empty the order of nodes is reversed, just search the correct link inverting the order
                link2_3idx = find(cell2mat(files{fileNo}.features.ID1) == node3ID & cell2mat(files{fileNo}.features.ID2) == node2ID);
                if strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
                    if layoutNo ~= 0
                        [link2_3LayoutAngleNode1, link2_3LayoutAngleNode2] = calculateLayoutLinkAngles(files{fileNo}.layout{layoutNo}, node3ID, node2ID, options); %calculate this angle using layout
                    else
                        %if isfield(files{fileNo}.features,'Y')
                        link2_3LayoutAngleNode1 = files{fileNo}.features.X.node2AngleOfLink{link2_3idx};
                        link2_3LayoutAngleNode2 = files{fileNo}.features.X.node1AngleOfLink{link2_3idx};
                        %end
                    end
                    
                    if isfield(files{fileNo}.features.X,'node1AngleOfLink') && ~isempty(files{fileNo}.features.X.node1AngleOfLink{link2_3idx,1}) && layoutNo > 2
                        link2_3AngleNode1Diff = link2_3LayoutAngleNode1 - files{fileNo}.features.X.node2AngleOfLink{link2_3idx,1};
                        link2_3AngleNode2Diff = link2_3LayoutAngleNode2 - files{fileNo}.features.X.node1AngleOfLink{link2_3idx,1};
                        
                        link2_3AngleNode1 = files{fileNo}.features.X.node2AngleOfLink{link2_3idx,1} + alpha*link2_3AngleNode1Diff;
                        link2_3AngleNode2 = files{fileNo}.features.X.node1AngleOfLink{link2_3idx,1} + alpha*link2_3AngleNode2Diff;
                    else
                        link2_3AngleNode1 = link2_3LayoutAngleNode1;
                        link2_3AngleNode2 = link2_3LayoutAngleNode2;
                    end
                    files{fileNo}.features.X.node2AngleOfLink{link2_3idx,1} = link2_3AngleNode1;
                    files{fileNo}.features.X.node1AngleOfLink{link2_3idx,1} = link2_3AngleNode2;
                end
            else
                if strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
                    if layoutNo ~= 0
                        [link2_3LayoutAngleNode1, link2_3LayoutAngleNode2] = calculateLayoutLinkAngles(files{fileNo}.layout{layoutNo}, node2ID, node3ID, options); %calculate this angle using layout
                    else
                        %if isfield(files{fileNo}.features,'Y')
                        link2_3LayoutAngleNode1 = files{fileNo}.features.X.node1AngleOfLink{link2_3idx};
                        link2_3LayoutAngleNode2 = files{fileNo}.features.X.node2AngleOfLink{link2_3idx};
                        %end
                    end
                    
                    if isfield(files{fileNo}.features.X,'node1AngleOfLink') && ~isempty(files{fileNo}.features.X.node1AngleOfLink{link2_3idx,1}) && layoutNo > 2
                        link2_3AngleNode1Diff = link2_3LayoutAngleNode1 - files{fileNo}.features.X.node1AngleOfLink{link2_3idx,1};
                        link2_3AngleNode2Diff = link2_3LayoutAngleNode2 - files{fileNo}.features.X.node2AngleOfLink{link2_3idx,1};
                        
                        link2_3AngleNode1 = files{fileNo}.features.X.node1AngleOfLink{link2_3idx,1} + alpha*link2_3AngleNode1Diff;
                        link2_3AngleNode2 = files{fileNo}.features.X.node2AngleOfLink{link2_3idx,1} + alpha*link2_3AngleNode2Diff;
                    else
                        link2_3AngleNode1 = link2_3LayoutAngleNode1;
                        link2_3AngleNode2 = link2_3LayoutAngleNode2;
                    end
                    
                    files{fileNo}.features.X.node1AngleOfLink{link2_3idx,1} = link2_3AngleNode1;
                    files{fileNo}.features.X.node2AngleOfLink{link2_3idx,1} = link2_3AngleNode2;
                end
            end
            
            link3_1idx = find(cell2mat(files{fileNo}.features.ID1) == node3ID & cell2mat(files{fileNo}.features.ID2) == node1ID);% | cell2mat(files{fileNo}.features.ID1) == node1ID & cell2mat(files{fileNo}.features.ID2) == node3ID);
            if isempty(link3_1idx)  %if it's empty the order of nodes is reversed, just search the correct link inverting the order
                link3_1idx = find(cell2mat(files{fileNo}.features.ID1) == node1ID & cell2mat(files{fileNo}.features.ID2) == node3ID);
                if strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
                    if layoutNo ~= 0
                        [link3_1LayoutAngleNode1, link3_1LayoutAngleNode2] = calculateLayoutLinkAngles(files{fileNo}.layout{layoutNo}, node1ID, node3ID, options); %calculate this angle using layout
                    else
                        %if isfield(files{fileNo}.features,'Y')
                        link3_1LayoutAngleNode1 = files{fileNo}.features.X.node2AngleOfLink{link3_1idx};
                        link3_1LayoutAngleNode2 = files{fileNo}.features.X.node1AngleOfLink{link3_1idx};
                        %end
                    end
                    
                    if isfield(files{fileNo}.features.X,'node1AngleOfLink') && ~isempty(files{fileNo}.features.X.node1AngleOfLink{link3_1idx,1}) && layoutNo > 2
                        link3_1AngleNode1Diff = link3_1LayoutAngleNode1 - files{fileNo}.features.X.node2AngleOfLink{link3_1idx,1};
                        link3_1AngleNode2Diff = link3_1LayoutAngleNode2 - files{fileNo}.features.X.node1AngleOfLink{link3_1idx,1};
                        
                        link3_1AngleNode1 = files{fileNo}.features.X.node2AngleOfLink{link3_1idx,1} + alpha*link3_1AngleNode1Diff;
                        link3_1AngleNode2 = files{fileNo}.features.X.node1AngleOfLink{link3_1idx,1} + alpha*link3_1AngleNode2Diff;
                    else
                        link3_1AngleNode1 = link3_1LayoutAngleNode1;
                        link3_1AngleNode2 = link3_1LayoutAngleNode2;
                    end
                    
                    files{fileNo}.features.X.node2AngleOfLink{link3_1idx,1} = link3_1AngleNode1;
                    files{fileNo}.features.X.node1AngleOfLink{link3_1idx,1} = link3_1AngleNode2;
                end
            else
                if strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
                    if layoutNo ~= 0
                        [link3_1LayoutAngleNode1, link3_1LayoutAngleNode2] = calculateLayoutLinkAngles(files{fileNo}.layout{layoutNo}, node3ID, node1ID, options); %calculate this angle using layout
                    else
                        %if isfield(files{fileNo}.features,'Y')
                        link3_1LayoutAngleNode1 = files{fileNo}.features.X.node1AngleOfLink{link3_1idx};
                        link3_1LayoutAngleNode2 = files{fileNo}.features.X.node2AngleOfLink{link3_1idx};
                        %end
                    end
                    
                    if isfield(files{fileNo}.features.X,'node1AngleOfLink') && ~isempty(files{fileNo}.features.X.node1AngleOfLink{link3_1idx,1}) && layoutNo > 2
                        link3_1AngleNode1Diff = link3_1LayoutAngleNode1 - files{fileNo}.features.X.node1AngleOfLink{link3_1idx,1};
                        link3_1AngleNode2Diff = link3_1LayoutAngleNode2 - files{fileNo}.features.X.node2AngleOfLink{link3_1idx,1};
                        
                        link3_1AngleNode1 = files{fileNo}.features.X.node1AngleOfLink{link3_1idx,1} + alpha*link3_1AngleNode1Diff;
                        link3_1AngleNode2 = files{fileNo}.features.X.node2AngleOfLink{link3_1idx,1} + alpha*link3_1AngleNode2Diff;
                    else
                        link3_1AngleNode1 = link3_1LayoutAngleNode1;
                        link3_1AngleNode2 = link3_1LayoutAngleNode2;
                    end
                    
                    files{fileNo}.features.X.node1AngleOfLink{link3_1idx,1} = link3_1AngleNode1;
                    files{fileNo}.features.X.node2AngleOfLink{link3_1idx,1} = link3_1AngleNode2;
                end
            end
            if strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
                if layoutNo > 2
                    diffs = [link1_2AngleNode1Diff;link1_2AngleNode2Diff;link2_3AngleNode1Diff;link2_3AngleNode2Diff;link3_1AngleNode1Diff;link3_1AngleNode2Diff];
                else
                    diffs = [link1_2AngleNode1;link1_2AngleNode2;link2_3AngleNode1;link2_3AngleNode2;link3_1AngleNode1;link3_1AngleNode2];
                end
                if triangleIdx == 1 || abs(max(abs(mod(diffs,2*pi)-pi)-pi)*options.RAD_TO_DEF_CONST) > maxAngleDiffDeg(1,1)
                    maxAngleDiffDeg = abs(max(abs(mod(diffs,2*pi)-pi)-pi)*options.RAD_TO_DEF_CONST);
                end
            end
            if (strcmp(setSelectionStr,'Train') && (files{fileNo}.features.set{link1_2idx}(1) == options.TRAIN_SET_LABEL_CONSTANT) && (files{fileNo}.features.set{link2_3idx}(1) == options.TRAIN_SET_LABEL_CONSTANT)  && (files{fileNo}.features.set{link3_1idx}(1) == options.TRAIN_SET_LABEL_CONSTANT)) || ...
                    (( (strcmp(setSelectionStr,'CrossValidation') || strcmp(setSelectionStr,'Test')) && options.MERGE_TEST_AND_CORSSVALIDATION) && (files{fileNo}.features.set{link1_2idx}(1) == options.CROSSVALIDATION_SET_LABEL_CONSTANT) && (files{fileNo}.features.set{link2_3idx}(1) == options.CROSSVALIDATION_SET_LABEL_CONSTANT)  && (files{fileNo}.features.set{link3_1idx}(1) == options.CROSSVALIDATION_SET_LABEL_CONSTANT)) || ...
                    (( (strcmp(setSelectionStr,'CrossValidation') || strcmp(setSelectionStr,'Test'))  && options.MERGE_TEST_AND_CORSSVALIDATION) && (files{fileNo}.features.set{link1_2idx}(1) == options.TEST_SET_LABEL_CONSTANT) && (files{fileNo}.features.set{link2_3idx}(1) == options.TEST_SET_LABEL_CONSTANT)  && (files{fileNo}.features.set{link3_1idx}(1) == options.TEST_SET_LABEL_CONSTANT)) || ...
                    strcmp(setSelectionStr,'All')
                
                rssiFeatures = [files{fileNo}.features.X.rssi{link1_2idx}, files{fileNo}.features.X.rssi{link2_3idx} , files{fileNo}.features.X.rssi{link3_1idx}];
                orientationFeatures = [files{fileNo}.features.X.node1Orientation{link1_2idx}, files{fileNo}.features.X.node2Orientation{link1_2idx}, files{fileNo}.features.X.node1Orientation{link2_3idx}, files{fileNo}.features.X.node2Orientation{link2_3idx}, files{fileNo}.features.X.node1Orientation{link3_1idx}, files{fileNo}.features.X.node2Orientation{link3_1idx}];
                if strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
                    linksAnglesFeature = [link1_2AngleNode1, link1_2AngleNode2, link2_3AngleNode1, link2_3AngleNode2, link3_1AngleNode1, link3_1AngleNode2]; %note:this cannot use features.Y!!!!!!
                    linksAnglesFeature = double(mod(linksAnglesFeature,2*pi));
                    linksAnglesFeature = (floor(linksAnglesFeature*1000000))/1000000; %use floor to avoid to overcome 2pi
                end
                
                if ~isempty(rssiFeatures)
                    if strcmp(model.inputDataType,options.ONLY_RSSI_DATA)
                        X = [X ; rssiFeatures];
                    elseif strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
                        %X = [X ; rssiFeatures,orientationFeatures,linksAnglesFeature];
                        X = [X ; rssiFeatures,linksAnglesFeature];
                    else
                        error('%s not valid selection when ANN2 model is used!', model.inputDataType);
                    end
                    %variables used for reconstruct map from triangles
                    orientationRec = [orientationRec ; orientationFeatures];
                    linksRec = [linksRec ; link1_2idx*ones(size(rssiFeatures,1),1), link2_3idx*ones(size(rssiFeatures,1),1), link3_1idx*ones(size(rssiFeatures,1),1)];
                    filesRec = [filesRec ; fileNo*ones(size(rssiFeatures,1),1)];
                    triangleRec = [triangleRec ; triangleIdx*ones(size(rssiFeatures,1),1)];
                    %sets = [sets ; set];
                end
            end
        end
    end
    if strcmp(model.inputDataType,options.RSSI_AND_ANGLES_DATA)
        %fprintf('Maximum difference between angles: %.2f\n',maxAngleDiffDeg);
        figure(55654)
        hold on
        plot(layoutNo,maxAngleDiffDeg,'o','lineWidth',3);
        grid on;
        xlabel('Iteration');
        ylabel('Max angle diff [deg]');
    end
    p=model.p;
    %Xpower = calculatePowerFeatures(Xtrain);
    XPoly = calculatePolynomialFeatures(X, p);
    
    %[XNorm, ~, ~] = featureNormalize(XPoly,model);
    XNorm = XPoly;
    %XNorm = [ones(size(XPoly,1),1), XNorm];
    
    yPredicted = sim(model.net,XNorm')';
    
    %reconstruct unidirectional links
    distanceEstim = [];
    orientation = [];
    availableFiles = unique(filesRec);
    fileOfEstim = [];% not an allocation!!!
    for fileI = 1 : size(availableFiles,1)
        
        selectIThFileData = filesRec == availableFiles(fileI);
        fileOfEstim(selectIThFileData) = availableFiles(fileI);
        fileLength = size(selectIThFileData,1);
        selectIThTriangleData = zeros(fileLength,1);
        availablesTriangles = unique(triangleRec(selectIThFileData));
        availableLinks = unique(linksRec(selectIThFileData,:));
        availableIds = unique([cell2mat(files{fileNo}.features.ID1) ;cell2mat(files{fileNo}.features.ID2) ] );
        noOfLinks = size(availableLinks,1);
        noOfTrianglesToAverage = zeros(noOfLinks,1);
        noOfTriangles = size(availablesTriangles,1);
        distanceEstimFileAccumulator = zeros(sum(selectIThFileData)/noOfTriangles,noOfLinks);
        distanceEstimFile = NaN*ones(sum(selectIThFileData)/noOfTriangles,noOfLinks,10);
        orientationFileAccumulator = zeros(sum(selectIThFileData)/noOfTriangles,size(availableIds,1));
        noOfNodesToAverage = zeros(size(availableIds,1) , 1);
        distanceGroundTruthFile = zeros(sum(selectIThFileData)/noOfTriangles,noOfLinks);
        linksRecFile = linksRec(selectIThFileData,:);
        yPredictedFile = yPredicted(selectIThFileData,:);
        orientationRecFile = orientationRec(selectIThFileData,:);
        linkID1 = cell2mat(files{fileNo}.features.ID1);
        linkID2 = cell2mat(files{fileNo}.features.ID2);
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
            
            noOfTrianglesToAverage(availableLinks == link1_2idx,1) = noOfTrianglesToAverage(availableLinks == link1_2idx,1) + 1;
            noOfTrianglesToAverage(availableLinks == link2_3idx,1) = noOfTrianglesToAverage(availableLinks == link2_3idx,1) + 1;
            noOfTrianglesToAverage(availableLinks == link3_1idx,1) = noOfTrianglesToAverage(availableLinks == link3_1idx,1) + 1;
            
            orientationFileAccumulator(:,availableIds == linkID1(link1_2idx)) = orientationFileAccumulator(:,availableIds == linkID1(link1_2idx)) + orientationRecFile( selectIThTriangleData, 1);
            orientationFileAccumulator(:,availableIds == linkID2(link1_2idx)) = orientationFileAccumulator(:,availableIds == linkID2(link1_2idx)) + orientationRecFile( selectIThTriangleData, 2);
            orientationFileAccumulator(:,availableIds == linkID1(link2_3idx)) = orientationFileAccumulator(:,availableIds == linkID1(link2_3idx)) + orientationRecFile( selectIThTriangleData, 3);
            orientationFileAccumulator(:,availableIds == linkID2(link2_3idx)) = orientationFileAccumulator(:,availableIds == linkID2(link2_3idx)) + orientationRecFile( selectIThTriangleData, 4);
            orientationFileAccumulator(:,availableIds == linkID1(link3_1idx)) = orientationFileAccumulator(:,availableIds == linkID1(link3_1idx)) + orientationRecFile( selectIThTriangleData, 5);
            orientationFileAccumulator(:,availableIds == linkID2(link3_1idx)) = orientationFileAccumulator(:,availableIds == linkID2(link3_1idx)) + orientationRecFile( selectIThTriangleData, 6);
            
            noOfNodesToAverage(availableIds == linkID1(link1_2idx),1) = noOfNodesToAverage(availableIds == linkID1(link1_2idx),1) + 1;
            noOfNodesToAverage(availableIds == linkID2(link1_2idx),1) = noOfNodesToAverage(availableIds == linkID2(link1_2idx),1) + 1;
            noOfNodesToAverage(availableIds == linkID1(link2_3idx),1) = noOfNodesToAverage(availableIds == linkID1(link2_3idx),1) + 1;
            noOfNodesToAverage(availableIds == linkID2(link2_3idx),1) = noOfNodesToAverage(availableIds == linkID2(link2_3idx),1) + 1;
            noOfNodesToAverage(availableIds == linkID1(link3_1idx),1) = noOfNodesToAverage(availableIds == linkID1(link3_1idx),1) + 1;
            noOfNodesToAverage(availableIds == linkID2(link3_1idx),1) = noOfNodesToAverage(availableIds == linkID2(link3_1idx),1) + 1;
        end
        
        distanceEstimFile = distanceEstimFile(:,:,1:mean(noOfTrianglesToAverage));
        distanceEstimFileAggregated = zeros(size(distanceEstimFileAccumulator));
        for linkNo = 1 : size(noOfTrianglesToAverage,1)
            distanceEstimFileAggregated(:,linkNo) = aggregateLinkLengthEstimations( distanceEstimFile(:,linkNo,:) , options);
        end
        
        for nodeNo = 1 : size(availableIds,1)
            orientationFileAccumulator(:,nodeNo) = orientationFileAccumulator(:,nodeNo) / noOfNodesToAverage(nodeNo,1); %pretty useless to average..... leave it just for keeping process the same for all variables
        end
        
        distanceEstim = [distanceEstim; distanceEstimFileAggregated];
        orientation = [orientation; orientationFileAccumulator];
    end
end

noOfSamples = size(distanceEstim,1);
%for linkIdx = 1:noOfLinks
%availableIds = unique([cell2mat(files{fileNo}.features.ID1) ; cell2mat(files{fileNo}.features.ID2)]);
%files{actualFileIdx}.layout{layoutNo+1} = cell(noOfSamples,1);
actualFileIdx = 0;
for sampleNo = 1 : noOfSamples
    linksDistances = distanceEstim(sampleNo,:);
    if actualFileIdx ~= fileOfEstim(sampleNo)
        withinFileIdx = 1;
        actualFileIdx = fileOfEstim(sampleNo);
    end
    linksId = [cell2mat(files{actualFileIdx}.features.ID1) , cell2mat(files{actualFileIdx}.features.ID2)];
    links.distance = linksDistances;
    links.id = linksId;
    links.timestamp = files{fileOfEstim(sampleNo)}.links.windowedSignal.timestamp{1}(withinFileIdx);
    
    if sampleNo == 1
        noOfNodes = size(unique(links.id),1);
        startingPos = rand(noOfNodes,2)*2-1;
        r = 100*max(links.distance(links.distance ~= Inf)); %avoid Infs
        deltaPhi_rad = (2*pi)/noOfNodes;
        for nodeNo = 1:noOfNodes
            startingPos(nodeNo,:) = [r*sin(deltaPhi_rad*nodeNo), r*cos(deltaPhi_rad*nodeNo)];
        end
        
    else
        startingPos = files{actualFileIdx}.layout{layoutNo+1}{sampleNo-1}.xy;
    end
    
    %     opt = optimset('LargeScale','off','GradObj', 'on','Display','notify-detailed', 'MaxIter', 5000,'MaxFunEvals',5000);
    %     opt = optimoptions('fminunc', ...
    %                        'SpecifyObjectiveGradient', true, ...
    %                        'Display','notify-detailed', ...
    %                        'MaxIterations', 5000, ...
    %                        'MaxFunctionEvaluations',5000, ...
    %                        'CheckGradients', false);
    opt = optimset('GradObj', 'on', ...
        'LargeScale','off', ...
        'Display','notify-detailed', ...
        'MaxIter', 5000, ...
        'MaxFunEvals',5000, ...
        'DerivativeCheck' , 'off');
    
    optimalPos = fminunc(@(pos)(layoutErrorCost(pos, links, options)), startingPos,opt);
    
    files{actualFileIdx}.layout{layoutNo+1}{sampleNo}.xy = optimalPos;
    [~, ~, id, energyMatrix, timestamp] = layoutErrorCost(optimalPos,links,options);
    files{actualFileIdx}.layout{layoutNo+1}{sampleNo}.id = id;
    files{actualFileIdx}.layout{layoutNo+1}{sampleNo}.timestamp = timestamp;
    files{actualFileIdx}.layout{layoutNo+1}{sampleNo}.energyMatrix = energyMatrix;
    files{actualFileIdx}.layout{layoutNo+1}{sampleNo}.orientation = orientation(sampleNo,:)';

    withinFileIdx = withinFileIdx + 1;
end
