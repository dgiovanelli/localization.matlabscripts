function links = rssiToDistanceConversion(links,options)

noOfLinks = size(links.IDrx,1);

if isfield(links,'rawSignal')
    links.rawSignal.distance = cell(noOfLinks,1);
    for linkNo = 1:noOfLinks
        links.rawSignal.distance{linkNo} = rssiToDistanceModel(links.rawSignal.rssi{linkNo},options);
    end
end

if isfield(links,'windowedSignal')
    links.windowedSignal.distance = cell(noOfLinks,1);
    for linkNo = 1:noOfLinks
        links.windowedSignal.distance{linkNo} = rssiToDistanceModel(links.windowedSignal.rssi{linkNo},options);
    end
end