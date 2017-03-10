function positionMatrix = extractPositionCombinationsMatrix(file) %%NO MORE NEEDED IN THE CODE

groundTruth = file.groundTruth;
links = file.links;

noOfLinks = size(groundTruth.referenceSignal.distance,1);
noOfTimeSamples = size(groundTruth.referenceSignal.timestamp{1},1);

distances = reshape(cell2mat(groundTruth.referenceSignal.distance),noOfTimeSamples,noOfLinks);
anglesOfArrivals = reshape(cell2mat(groundTruth.referenceSignal.angleOfArrival),noOfTimeSamples,noOfLinks);
anglesOfDepartures = reshape(cell2mat(groundTruth.referenceSignal.angleOfDeparture),noOfTimeSamples,noOfLinks);
txNodeOrientations = reshape(cell2mat(groundTruth.referenceSignal.txNodeOrientation),noOfTimeSamples,noOfLinks);
rxNodeOrientations = reshape(cell2mat(groundTruth.referenceSignal.rxNodeOrientation),noOfTimeSamples,noOfLinks);

rssis = reshape(cell2mat(links.windowedSignal.rssi),noOfTimeSamples,noOfLinks);

if size(rssis,1) ~= size(distances,1)
    error('The one dimensional version of links.windowedSignal.rssi has a different dimension than groundTruth.referenceSignal.distance');
end

distancesValues = unique(distances);
anglesOfArrivalsValues = unique(anglesOfArrivals(~isnan(anglesOfArrivals)));
anglesOfDeparturesValues = unique(anglesOfDepartures(~isnan(anglesOfDepartures)));
txNodeOrientationsValues = unique(txNodeOrientations(~isnan(txNodeOrientations)));
rxNodeOrientationsValues = unique(rxNodeOrientations(~isnan(rxNodeOrientations)));

noOfDistances = size(distancesValues,1);
noOfAnglesOfArrivals = size(anglesOfArrivalsValues,1);
noOfAnglesOfDepartures = size(anglesOfDeparturesValues,1);
noOfRxNodeOrientationsValues = size(txNodeOrientationsValues,1);
noOfTxNodeOrientationsValues = size(rxNodeOrientationsValues,1);

positionMatrix.networkPoV.rssi.values = cell(noOfDistances,noOfAnglesOfArrivals,noOfAnglesOfDepartures);
positionMatrix.networkPoV.rssi.linksIdx = cell(noOfDistances,noOfAnglesOfArrivals,noOfAnglesOfDepartures);
positionMatrix.networkPoV.valuesOfDistance = distancesValues;
positionMatrix.networkPoV.valuesOfAnglesOfArrivals = anglesOfArrivalsValues;
positionMatrix.networkPoV.valuesOfAnglesOfDepartures = anglesOfDeparturesValues;

positionMatrix.nodePoV.rssi.values = cell(noOfDistances,noOfAnglesOfArrivals,noOfAnglesOfDepartures);
positionMatrix.nodePoV.rssi.linksIdx = cell(noOfDistances,noOfAnglesOfArrivals,noOfAnglesOfDepartures);
positionMatrix.nodePoV.valuesOfDistance = distancesValues;
positionMatrix.nodePoV.valuesRxNodeOrientations = txNodeOrientationsValues;
positionMatrix.nodePoV.valuesTxNodeOrientations = rxNodeOrientationsValues;

for distanceIdx = 1 : noOfDistances
    for angleOfArrivalIdx = 1 : noOfAnglesOfArrivals
        for angleOfDepartureIdx = 1 : noOfAnglesOfDepartures
            validRssiIdxs = (distances == distancesValues(distanceIdx) & anglesOfArrivals == anglesOfArrivalsValues(angleOfArrivalIdx) & anglesOfDepartures == anglesOfDeparturesValues(angleOfDepartureIdx));
            if(~isempty(find(validRssiIdxs, 1)))
                samplesToInclude = rssis(validRssiIdxs);
                positionMatrix.networkPoV.rssi.values{distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx} = cat(1,positionMatrix.networkPoV.rssi.values{distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx},samplesToInclude);

                linkIdxs = find(sum(validRssiIdxs,1)); %calculates the indexes of the links where the rssi values have been bringed
                linkIdxsTs = ones(noOfTimeSamples,1) * linkIdxs; %since the links are fixed we know the length of valid samples for this rssis(distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx) will equal the total length (in time) of the whole acquisition
                linkIdxsTs = linkIdxsTs(:); 
                positionMatrix.networkPoV.rssi.linksIdx{distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx} = cat(1,positionMatrix.networkPoV.rssi.linksIdx{distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx},linkIdxsTs);
            end
        end
    end
    
    for rxOrientationIdx = 1 : noOfRxNodeOrientationsValues
        for txOrientationIdx = 1 : noOfTxNodeOrientationsValues
            validRssiIdxs = (distances == distancesValues(distanceIdx) & rxNodeOrientations == rxNodeOrientationsValues(rxOrientationIdx) & txNodeOrientations == txNodeOrientationsValues(txOrientationIdx));
            if(~isempty(find(validRssiIdxs, 1)))
                samplesToInclude = rssis(validRssiIdxs);
                positionMatrix.nodePoV.rssi.values{distanceIdx,rxOrientationIdx,txOrientationIdx} = cat(1,positionMatrix.nodePoV.rssi.values{distanceIdx,rxOrientationIdx,txOrientationIdx},samplesToInclude);

                linkIdxs = find(sum(validRssiIdxs,1)); %calculates the indexes of the links where the rssi values have been bringed
                linkIdxsTs = ones(noOfTimeSamples,1) * linkIdxs; %since the links are fixed we know the length of valid samples for this rssis(distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx) will equal the total length (in time) of the whole acquisition
                linkIdxsTs = linkIdxsTs(:);
                positionMatrix.nodePoV.rssi.linksIdx{distanceIdx,rxOrientationIdx,txOrientationIdx} = cat(1,positionMatrix.nodePoV.rssi.linksIdx{distanceIdx,rxOrientationIdx,txOrientationIdx},linkIdxsTs);
            end
        end
    end
end

end

