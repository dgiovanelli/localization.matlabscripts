clear
close all

%constant are loaded in the 'options' struct
importOptions;

%open the file and get the file id to extract data. The file path is taken from the options
fileID = openFile(options);

%extract data from file and store it in structs
%   packets  -> contains timestamp, raw BLE payload, type ('ADV' or 'GATT') for every BLE packet logged
%   tags     -> contains timestamp, tags payload (identifier string), type (always 'TAG') for every tag logged
[packets, tags] = extractPacketsFromFile(fileID,options);

%extract rssi signals for every link in the network and store it in a struct
links = extractLinkSignals(packets,options);

%prefilter data using the average in a sliding window. This return signals with constant samplig dt = winc_s
links.windowedSignal = slidingWindowAvg(links.rawSignal, options);

%convert rssi data to meters using the fade model
[links.rawSignal.distance, links.windowedSignal.distance] = rssiToDistanceConversion(links,options);

S = createNetworkMatrixFromLinks(links,options);

%plot some data
plotSomeResult(links,S,options);

links2 = createLinksFromNetworkMatrix(S,options);

