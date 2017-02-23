clear

filePath = 'F:\GDrive\CLIMB\WIRELESS\LOG\LOCALIZATION\MUSE_21_02_2016\LOGS\log_52_15.26.30.txt';

%open the file and get the file id to extract data
fileID = openFile(filePath);

%extract data from file and store it in structs
%   packets  -> contains timestamp, raw BLE payload, type ('ADV' or 'GATT') for every BLE packet logged
%   tags     -> contains timestamp, tags payload (identifier string), type (always 'TAG') for every tag logged
[packets, tags] = extractPacketsFromFile(fileID);

links = extractLinkSignals(packets);
