function positionMatrix = extractPositionCombinationsMatrix(groundTruth,links)

noOfLinks = size(groundTruth.referenceSignal.distance,1);
noOfTimeSamples = size(groundTruth.referenceSignal.timestamp{1},1);

distances = reshape(cell2mat(groundTruth.referenceSignal.distance),noOfTimeSamples,noOfLinks);
anglesOfArrivals = reshape(cell2mat(groundTruth.referenceSignal.angleOfArrival),noOfTimeSamples,noOfLinks);
anglesOfDepartures = reshape(cell2mat(groundTruth.referenceSignal.angleOfDeparture),noOfTimeSamples,noOfLinks);

rssis = reshape(cell2mat(links.windowedSignal.rssi),noOfTimeSamples,noOfLinks);

if size(rssis,1) ~= size(distances,1)
    error('The one dimensional version of links.windowedSignal.rssi has a different dimension than groundTruth.referenceSignal.distance');
end

distancesValues = unique(distances);
anglesOfArrivalsValues = unique(anglesOfArrivals(~isnan(anglesOfArrivals)));
anglesOfDeparturesValues = unique(anglesOfDepartures(~isnan(anglesOfDepartures)));

noOfDistances = size(distancesValues,1);
noOfAnglesOfArrivals = size(anglesOfArrivalsValues,1);
noOfAnglesOfDepartures = size(anglesOfDeparturesValues,1);

positionMatrix.rssi.value = cell(noOfDistances,noOfAnglesOfArrivals,noOfAnglesOfDepartures);
positionMatrix.rssi.linksIdx = cell(noOfDistances,noOfAnglesOfArrivals,noOfAnglesOfDepartures);
positionMatrix.valuesOfDistance = distancesValues;
positionMatrix.valuesOfAnglesOfArrivals = anglesOfArrivalsValues;
positionMatrix.valuesOfAnglesOfDepartures = anglesOfDeparturesValues;

for distanceIdx = 1 : noOfDistances
    for angleOfArrivalIdx = 1 : noOfAnglesOfArrivals
        for angleOfDepartureIdx = 1 : noOfAnglesOfDepartures
            validRssiIdxs = (distances == distancesValues(distanceIdx) & anglesOfArrivals == anglesOfArrivalsValues(angleOfArrivalIdx) & anglesOfDepartures == anglesOfDeparturesValues(angleOfDepartureIdx));
            if(~isempty(find(validRssiIdxs, 1)))
                samplesToInclude = rssis(validRssiIdxs);
                positionMatrix.rssi.value{distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx} = cat(1,positionMatrix.rssi.value{distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx},samplesToInclude);

                linkIdxs = find(sum(validRssiIdxs,1)); %calculates the indexes of the links where the rssi values have been bringed
                linkIdxsTs = ones(noOfTimeSamples,1) * linkIdxs; %since the links are fixed we know the length of valid samples for this rssis(distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx) will equal the total length (in time) of the whole acquisition
                linkIdxsTs = linkIdxsTs(:); 
                positionMatrix.rssi.linksIdx{distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx} = cat(1,positionMatrix.rssi.linksIdx{distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx},linkIdxsTs);
            end
        end
    end
end

end

