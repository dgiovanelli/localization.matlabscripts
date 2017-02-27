function links = createLinksFromNetworkMatrix(S,options)

availableIDs = sort( S.IDs );

N = size(availableIDs,1);
noOfLinks = N^2;

links.IDrx = cell(noOfLinks,1);
links.IDtx = cell(noOfLinks,1);
links.windowedSignal.rssi = cell(noOfLinks,1);
links.windowedSignal.distance = cell(noOfLinks,1);
links.windowedSignal.timestamp = cell(noOfLinks,1);

for rxIdx = 1:N
    for txIdx = 1:N
        linkIdx = rxIdx + (txIdx-1)*N;
        
        links.IDrx{linkIdx} = availableIDs(rxIdx);
        links.IDtx{linkIdx} = availableIDs(txIdx);
        
        rxIdxInS = findID(availableIDs(rxIdx), S.IDs); %the id contained in availableIDs(rxIdx) is searched in the IDs of the S matrix. Using this the resulting links are oredered by increasing id
        txIdxInS = findID(availableIDs(rxIdx), S.IDs); %the id contained in availableIDs(rxIdx) is searched in the IDs of the S matrix. Using this the resulting links are oredered by increasing id
        
        links.windowedSignal.rssi{linkIdx} = S.rssi(rxIdxInS,txIdxInS,:);
        links.windowedSignal.distance{linkIdx} = S.distance(rxIdxInS,txIdxInS,:);
        links.windowedSignal.timestamp{linkIdx} = S.timestamp;
    end
end
