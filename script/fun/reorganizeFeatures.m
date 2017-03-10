function features = reorganizeFeatures(file,options)

noOfLinks = size(file.links.IDrx,1);
noOfTimeSamples = size(file.links.windowedSignal.timestamp{1},1);
noOfNodes = sqrt(noOfLinks);

IDtx = cell2mat(file.links.IDtx);
IDrx = cell2mat(file.links.IDrx);

rxNodeOrientation = file.links.windowedSignal.rxNodeOrientation;
txNodeOrientation = file.links.windowedSignal.txNodeOrientation;

rssi = reshape(cell2mat(file.links.windowedSignal.rssi),noOfTimeSamples,noOfLinks);

if(mod(noOfNodes,1) ~= 0)
    warning('noOfNodes is not an integer value!');
end

rssiAggregated = cell(noOfNodes*(noOfNodes-1)/2 , 1);
rssiAggregatedStd = cell(noOfNodes*(noOfNodes-1)/2 , 1);
rssiAggregatedMean = cell(noOfNodes*(noOfNodes-1)/2 , 1);
ID1 = cell(noOfNodes*(noOfNodes-1)/2 , 1);
ID2 = cell(noOfNodes*(noOfNodes-1)/2 , 1);
node1Orientation = cell(noOfNodes*(noOfNodes-1)/2 , 1); 
node2Orientation = cell(noOfNodes*(noOfNodes-1)/2 , 1);
distance = cell(noOfNodes*(noOfNodes-1)/2 , 1);
node1AngleOfLink = cell(noOfNodes*(noOfNodes-1)/2 , 1);
node2AngleOfLink = cell(noOfNodes*(noOfNodes-1)/2 , 1);
set = cell(noOfNodes*(noOfNodes-1)/2 , 1);
doubleLinkIdx = 1;

for node1No = 1:noOfNodes-1
    for node2No = node1No+1:noOfNodes
        linkNo = node1No+(node2No-1)*(noOfNodes);
        
        rxID = IDrx(linkNo);
        txID = IDtx(linkNo);
                
        if(txID~=rxID)
            simmetricLinkNo = find(IDtx == rxID & IDrx == txID);
            if(size(simmetricLinkNo,1) ~= 1)
                error('Wrong amount of simmetric links (more than 1 or 0)');
            end
            rssiAggregated{doubleLinkIdx} = mean([rssi(:,linkNo) , rssi(:,simmetricLinkNo)],2);
            rssiAggregatedMean{doubleLinkIdx} = nanmean(rssiAggregated{doubleLinkIdx});
            rssiAggregatedStd{doubleLinkIdx} = nanstd(rssiAggregated{doubleLinkIdx});
            ID1{doubleLinkIdx} = rxID;
            ID2{doubleLinkIdx} = txID;
            node1Orientation{doubleLinkIdx} = rxNodeOrientation{linkNo};
            node2Orientation{doubleLinkIdx} = txNodeOrientation{linkNo};
            tempSamplesIdx = 1:1:noOfTimeSamples;

            if isfield(file,'groundTruth')
                set{doubleLinkIdx} = zeros(size(rssiAggregated{doubleLinkIdx})); %initializa variable
                set{doubleLinkIdx}(randsample(tempSamplesIdx,round(noOfTimeSamples*0.6))) = options.TRAIN_SET_LABEL_CONSTANT;
                
                tempSamplesIdx = find(set{doubleLinkIdx} ~= options.TRAIN_SET_LABEL_CONSTANT);
                set{doubleLinkIdx}(randsample(tempSamplesIdx,round(noOfTimeSamples*0.2))) = options.CROSSVALIDATION_SET_LABEL_CONSTANT; %2 = cross validationset
                tempSamplesIdx = find(set{doubleLinkIdx} ~= options.TRAIN_SET_LABEL_CONSTANT & set{doubleLinkIdx} ~= options.CROSSVALIDATION_SET_LABEL_CONSTANT);
                
                set{doubleLinkIdx}(tempSamplesIdx) = options.TEST_SET_LABEL_CONSTANT; %3 = test set
%                 set{doubleLinkIdx}(randsample(tempSamplesIdx(tempSamplesIdx~=1),round(noOfTimeSamples*0.6))) = 2; %2 = cross validationset 
%                 set{doubleLinkIdx}(randsample(tempSamplesIdx(tempSamplesIdx~=1 & ),round(noOfTimeSamples*0.6))) = 2;
                
                if(find(set{doubleLinkIdx} == 0,1))
                    warning('The random selection has left some samples to zero');
                end

                distance{doubleLinkIdx} = file.groundTruth.referenceSignal.distance{linkNo};
                
                node1AngleOfLink{doubleLinkIdx} = file.groundTruth.referenceSignal.angleOfArrival{linkNo};
                node2AngleOfLink{doubleLinkIdx} = file.groundTruth.referenceSignal.angleOfDeparture{linkNo};
            end
            doubleLinkIdx = doubleLinkIdx + 1;
        end
    end
end

features.ID1 = ID1;
features.ID2 = ID2;
features.X.rssi = rssiAggregated;
features.X.node1Orientation = node1Orientation;
features.X.node2Orientation = node2Orientation;
%extracted features
features.X.rssiMean = rssiAggregatedMean;
features.X.rssiStd = rssiAggregatedStd;


%known output (if provided)
if isfield(file,'groundTruth')
    features.set = set;
    
    features.Y.distance = distance;
    features.Y.node1AngleOfLink = node1AngleOfLink;
    features.Y.node2AngleOfLink = node2AngleOfLink;
end

end