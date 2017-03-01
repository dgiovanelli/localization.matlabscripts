function positionMatrix = extractPositionCombinationsMatrix(groundTruth,links)

distances = cell2mat(groundTruth.referenceSignal.distance);
anglesOfArrivals = cell2mat(groundTruth.referenceSignal.angleOfArrival);
anglesOfDepartures = cell2mat(groundTruth.referenceSignal.angleOfDeparture);

rssis = cell2mat(links.windowedSignal.rssi);

if size(rssis,1) ~= size(distances,1)
    error('The one dimensional version of links.windowedSignal.rssi has a different dimension than groundTruth.referenceSignal.distance');
end

distancesValues = unique(distances);
anglesOfArrivalsValues = unique(anglesOfArrivals(~isnan(anglesOfArrivals)));
anglesOfDeparturesValues = unique(anglesOfDepartures(~isnan(anglesOfDepartures)));

noOfDistances = size(distancesValues,1);
noOfAnglesOfArrivals = size(anglesOfArrivalsValues,1);
noOfAnglesOfDepartures = size(anglesOfDeparturesValues,1);

positionMatrix.rssi = cell(noOfDistances,noOfAnglesOfArrivals,noOfAnglesOfDepartures);
positionMatrix.valuesOfDistance = distancesValues;
positionMatrix.valuesOfAnglesOfArrivals = anglesOfArrivalsValues;
positionMatrix.valuesOfAnglesOfDepartures = anglesOfDeparturesValues;

for distanceIdx = 1 : noOfDistances
    for angleOfArrivalIdx = 1 : noOfAnglesOfArrivals
        for angleOfDepartureIdx = 1 : noOfAnglesOfDepartures
            samplesToInclude = rssis(distances == distancesValues(distanceIdx) & anglesOfArrivals == anglesOfArrivalsValues(angleOfArrivalIdx) & anglesOfDepartures == anglesOfDeparturesValues(angleOfDepartureIdx));
            positionMatrix.rssi{distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx} = cat(1,positionMatrix.rssi{distanceIdx,angleOfArrivalIdx,angleOfDepartureIdx},samplesToInclude);
        end
    end
end

