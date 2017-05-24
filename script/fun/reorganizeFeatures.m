function features = reorganizeFeatures(file,options)

setPartitionPolicy = 3;
if setPartitionPolicy == 2
    warning('No validation set when using setPartitionPolicy = 2')
end
noOfLinks = size(file.links.IDrx,1);
noOfTimeSamples = size(file.links.windowedSignal.timestamp{1},1);
noOfNodes = sqrt(noOfLinks);
noOfBiLink = noOfNodes*(noOfNodes - 1) / 2;


IDtx = cell2mat(file.links.IDtx);
IDrx = cell2mat(file.links.IDrx);

if isfield(file.links.windowedSignal,'rxNodeOrientation')
    rxNodeOrientation = file.links.windowedSignal.rxNodeOrientation;
    txNodeOrientation = file.links.windowedSignal.txNodeOrientation;
end

rssi = reshape(cell2mat(file.links.windowedSignal.rssi),noOfTimeSamples,noOfLinks);

if(mod(noOfNodes,1) ~= 0)
    warning('noOfNodes is not an integer value!');
end

rssiAggregated = cell(noOfNodes*(noOfNodes-1)/2 , 1);
rssiAggregatedStd = cell(noOfNodes*(noOfNodes-1)/2 , 1);
rssiAggregatedMean = cell(noOfNodes*(noOfNodes-1)/2 , 1);
ID1 = cell(noOfNodes*(noOfNodes-1)/2 , 1);
ID2 = cell(noOfNodes*(noOfNodes-1)/2 , 1);
if isfield(file.links.windowedSignal,'rxNodeOrientation')
    node1Orientation = cell(noOfNodes*(noOfNodes-1)/2 , 1);
    node2Orientation = cell(noOfNodes*(noOfNodes-1)/2 , 1);
end
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
            if isfield(file.links.windowedSignal,'rxNodeOrientation')
                node1Orientation{doubleLinkIdx} = rxNodeOrientation{linkNo};
                node2Orientation{doubleLinkIdx} = txNodeOrientation{linkNo};
            end
            tempSamplesIdx = 1:1:noOfTimeSamples;
            
            if isfield(file,'groundTruth')
                distance{doubleLinkIdx} = file.groundTruth.referenceSignal.distance{linkNo};
                
                node1AngleOfLink{doubleLinkIdx} = file.groundTruth.referenceSignal.angleOfArrival{linkNo};
                node2AngleOfLink{doubleLinkIdx} = file.groundTruth.referenceSignal.angleOfDeparture{linkNo};
            end
            doubleLinkIdx = doubleLinkIdx + 1;
        end
    end
    
    features.ID1 = ID1;
    features.ID2 = ID2;
    features.X.rssi = rssiAggregated;
    if isfield(file.links.windowedSignal,'rxNodeOrientation')
        features.X.node1Orientation = node1Orientation;
        features.X.node2Orientation = node2Orientation;
    end
    %extracted features
    features.X.rssiMean = rssiAggregatedMean;
    features.X.rssiStd = rssiAggregatedStd;
    
    
    %known output (if provided)
    if isfield(file,'groundTruth')      
        features.Y.distance = distance;
        features.Y.node1AngleOfLink = node1AngleOfLink;
        features.Y.node2AngleOfLink = node2AngleOfLink;
    end
    
end