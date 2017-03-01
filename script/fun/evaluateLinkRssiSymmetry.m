function S = evaluateLinkRssiSymmetry(S,options)

noOfNodes = size(S.IDs,1);
S.aggregatedLinkStandardDeviation = zeros(size(S.rssi,1),size(S.rssi,2),1);
S.linkStandardDeviation = zeros(size(S.rssi,1),size(S.rssi,2),1);
aggregatedMeanStd = 0;
meanStd = 0;

for rxNodeIdx = 1 : noOfNodes - 1
    for txNodeIdx = rxNodeIdx + 1 : noOfNodes
        %extract data to use in the loop
        directLinkRssi = reshape(S.rssi(rxNodeIdx,txNodeIdx,:),[size(S.rssi,3),1,1]);
        inverseLinkRssi = reshape(S.rssi(txNodeIdx,rxNodeIdx,:),[size(S.rssi,3),1,1]);
        dirInvLinkRssi = [directLinkRssi , inverseLinkRssi];
        
        %calculate non-aggregated std dev
        directLinkRssi = directLinkRssi(~isnan(directLinkRssi));
        inverseLinkRssi = inverseLinkRssi(~isnan(inverseLinkRssi));
        S.linkStandardDeviation(rxNodeIdx, txNodeIdx) = std(directLinkRssi);
        S.linkStandardDeviation(txNodeIdx, rxNodeIdx) = std(inverseLinkRssi);
        meanStd = meanStd + S.linkStandardDeviation(rxNodeIdx, txNodeIdx) + S.linkStandardDeviation(txNodeIdx, rxNodeIdx);
        
        %calculate aggregated std dev
        aggregatedLinkRssi = nanmean(dirInvLinkRssi,2); %use mean to aggregate!
        aggregatedLinkRssi = aggregatedLinkRssi(~isnan(aggregatedLinkRssi)); %if both links are NaN in at some time the previous line return NaN, then remove it
        S.aggregatedLinkStandardDeviation(rxNodeIdx, txNodeIdx) = std(aggregatedLinkRssi);%sum((aggregatedLinkRssi - meanRssi).^2) / noOfTimeSamples;
        aggregatedMeanStd = aggregatedMeanStd + S.aggregatedLinkStandardDeviation(rxNodeIdx, txNodeIdx); %accumulate for calculating the average
    end
end
%calculate the average std for non-aggregated and aggregated data
noOfLinks = noOfNodes*(noOfNodes-1)/2;
S.linksMeanStandardDeviation = meanStd/(2*noOfLinks); %here the links are uni directional: (N*N-1) links
S.aggregatedLinksMeanStandardDeviation = aggregatedMeanStd/noOfLinks; %here the links are bi directional:  (N*N-1)/2 links
