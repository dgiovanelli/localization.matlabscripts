function S = createAdjacencyMatrixFromLinks(links,options)

availableIDs = unique(cell2mat(links.IDrx)); %it should be already ordered!

N = size(availableIDs,1);
noOfTimeSamples = size(links.windowedSignal.timestamp{1},1);

S.rssi = -Inf*ones(N,N,noOfTimeSamples);
S.distance = Inf*ones(N,N,noOfTimeSamples);
S.timestamp = links.windowedSignal.timestamp{1};
S.IDs = availableIDs;

for rxIdx = 1:N
    for txIdx = 1:N
        linkIdx = rxIdx + (txIdx-1)*N;
        S.rssi(rxIdx,txIdx,:) = links.windowedSignal.rssi{linkIdx};
        S.distance(rxIdx,txIdx,:) = links.windowedSignal.distance{linkIdx};
    end
end

