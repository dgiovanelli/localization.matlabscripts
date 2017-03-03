function links = decimateSamples(links,options)

noOfLinks = size(links.IDrx,1);
decimationFactor = options.DECIMATION_FACTOR;

links.decimatedSignal.rssi = cell(noOfLinks,1);
links.decimatedSignal.distance = cell(noOfLinks,1);
links.decimatedSignal.timestamp = cell(noOfLinks,1);
links.decimatedSignal.rxNodeOrientation = cell(noOfLinks,1);
links.decimatedSignal.rtxNodeOrientation = cell(noOfLinks,1);

for linkNo = 1:noOfLinks
    links.decimatedSignal.rssi{linkNo} = links.windowedSignal.rssi{linkNo}(1:decimationFactor:end);
    links.decimatedSignal.distance{linkNo} = links.windowedSignal.distance{linkNo}(1:decimationFactor:end);
    links.decimatedSignal.timestamp{linkNo} = links.windowedSignal.timestamp{linkNo}(1:decimationFactor:end);
    links.decimatedSignal.rxNodeOrientation{linkNo} = links.windowedSignal.rxNodeOrientation{linkNo}(1:decimationFactor:end);
    links.decimatedSignal.txNodeOrientation{linkNo} = links.windowedSignal.txNodeOrientation{linkNo}(1:decimationFactor:end);
end