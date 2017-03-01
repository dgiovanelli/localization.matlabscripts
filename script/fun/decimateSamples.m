function links = decimateSamples(links,options)

noOfLinks = size(links.IDrx,1);

links.decimatedSignal.rssi = cell(noOfLinks,1);
links.decimatedSignal.distance = cell(noOfLinks,1);
links.decimatedSignal.timestamp = cell(noOfLinks,1);

decimationFactor = options.DECIMATION_FACTOR;

for linkNo = 1:noOfLinks
    links.decimatedSignal.rssi{linkNo} = links.windowedSignal.rssi{linkNo}(1:decimationFactor:end);
    links.decimatedSignal.distance{linkNo} = links.windowedSignal.distance{linkNo}(1:decimationFactor:end);
    links.decimatedSignal.timestamp{linkNo} = links.windowedSignal.timestamp{linkNo}(1:decimationFactor:end);
end