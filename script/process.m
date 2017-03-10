clear
close all
clc

%constant are loaded in the 'options' struct
importOptions;

%open the file and get the file id to extract data. The file path is taken from the options
fileID = openFile(options);

noOfFile = size(fileID,1);
file = cell(noOfFile,1);
for fileIdx = 1 : noOfFile
    %file{fileIdx}.links = getLinksFromFile(fileID(fileIdx,1),options);
    
    %extract data from file and store it in structs
    %   packets  -> contains timestamp, raw BLE payload, type ('ADV' or 'GATT' or 'TAG') for every BLE packet logged
    packets = extractPacketsFromFile(fileID(fileIdx,1),options);
    
    %extract rssi signals for every link in the network and store it in a struct
    file{fileIdx}.links = extractLinkSignals(packets,options);
    
    %prefilter data using the average in a sliding window. This return signals with constant samplig dt = winc_s
    file{fileIdx}.links = slidingWindowAvg(file{fileIdx}.links, options); %the returned value of 'links' is the same of the input argument 'links' plus the field '.windowedSignal'
    
    if isfield(options,'GROUND_TRUTH_FILE_PATH') %this means that the ground truth are provided
        positions = extractGroundTruthFromFile(fileIdx,options);
        file{fileIdx}.groundTruth = extractGroundTruthLinkSignals(positions,file{fileIdx}.links,options);
        file{fileIdx}.positionMatrix = extractPositionCombinationsMatrix(file{fileIdx});
        %the next two lines add the nodes orientation to the acquired signal. This is necessary because the SensorTag firmware, for now, doesn't support the acquisition of magnetometer
        %when the magnetometer data will be available, this information will be added directly in extractLinkSignals(..)
        file{fileIdx}.links.windowedSignal.rxNodeOrientation = file{fileIdx}.groundTruth.referenceSignal.rxNodeOrientation;
        file{fileIdx}.links.windowedSignal.txNodeOrientation = file{fileIdx}.groundTruth.referenceSignal.txNodeOrientation;
    end

    file{fileIdx}.features = reorganizeFeatures(file{fileIdx},options);
    %convert rssi data to meters using the fade model
%     file{fileIdx}.links = rssiToDistanceConversion(file{fileIdx}.links,options); %the returned value of 'links' is the same of the input argument 'links' plus the fields 'rawSignal.distance' and '.windowedSignal.distance'
%     
%     %extract the adjancency matrix (S) from the links signals
%     file{fileIdx}.S = createAdjacencyMatrixFromLinks(file{fileIdx}.links,options);
%     
%     %evaluate the symmetry of the links by aggregating the two direction of the link. 
%     %This returns the std dev (over time) of the aggregate rssi (the average, sample by sample, between the two directions).
%     file{fileIdx}.S = evaluateLinkRssiSymmetry(file{fileIdx}.S,options);
%     
%     %file{fileIdx}.links = createLinksFromAdjacencyMatrix(file{fileIdx}.S,options); %this overwrite the variable 'links'.
%     
%     %apply decimation (only to windowed signals)
%     file{fileIdx}.links = decimateSamples(file{fileIdx}.links,options); %the returned value of 'links' is the same of the input argument 'links' plus the field '.decimatedSignal'
%     
    fprintf('\nFile %d of %d done!',fileIdx,noOfFile);
end
fprintf('\n');

model = trainModel(file,options);
model.trainError = calculateError(file,model,options,'Train');
model.crossVError = calculateError(file,model,options,'CrossValidation');
model.testError = calculateError(file,model,options,'Test');

plotModelWithTrainingData(file,model,options);

%plot some data
plotSomeResult(file,options);

%TODOs:
%trainare il modello di fading considerando solo la distanza, la distanza + un angolo (info aggregata), la distanza con due angoli
