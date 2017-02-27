function [rawSignalDistance, windowedSignalDistance] = rssiToDistanceConversion(links,options)

noOfLinks = size(links.IDrx,1);

rawSignalDistance = cell(noOfLinks,1);
windowedSignalDistance = cell(noOfLinks,1);

for linkNo = 1:noOfLinks
    rawSignalDistance{linkNo} = rssiToDistanceModel(links.rawSignal.rssi{linkNo},options);
    windowedSignalDistance{linkNo} = rssiToDistanceModel(links.windowedSignal.rssi{linkNo},options);
end