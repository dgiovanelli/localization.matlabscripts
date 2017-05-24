function linkLength = aggregateLinkLengthEstimations(linkLengthEstimations, options)
aggregationPolicy = options.MULTIPLE_ESTIMATION_AGGREGATION_POLICY;
if aggregationPolicy == 1
    linkLength = nanmean(linkLengthEstimations,3);
elseif  aggregationPolicy == 2
    linkLengthEstimations = reshape(linkLengthEstimations,[size(linkLengthEstimations,1), size(linkLengthEstimations,3)]);
    noOfSamples = size(linkLengthEstimations,1);
    linkLength = zeros(noOfSamples,1);
    for timeIdx = 1 : noOfSamples
        if sum(isnan(linkLengthEstimations(timeIdx,:))) == size(linkLengthEstimations,2)
            linkLength(timeIdx) = NaN;
        else
            [N, edges] = histcounts(linkLengthEstimations(timeIdx,:),10);
            [~, binIdx] = max(N);
            mostProbableBinIdx = find(N == N(binIdx));
            
            linkLength(timeIdx) = mean( [edges(mostProbableBinIdx),edges(mostProbableBinIdx+1)] );
        end
    end
end
end