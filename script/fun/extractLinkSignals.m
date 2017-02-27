function links = extractLinkSignals(packets,options)

%%DISCOVER ALL IDS
availableIDs = zeros(5,1);
availableIDsIdx = 1;
for packetIdx = 1:size(packets.timestamp,1)
    if strcmp( packets.type(packetIdx) , options.ADV_TYPE_IDENTIFIER )
        %check the receiver ID
        IDrx = sscanf(packets.payload{packetIdx}(1:2),'%x'); %read the ID of the receiver (i.e. the owner of this packet)
        if isValidRxID(IDrx,options)
            if findID(IDrx, availableIDs) == 0 %check if the ID is already in availableIDs, if not add it
                if availableIDsIdx == size(availableIDs,1) %resize availableIDs
                    availableIDs = cat(1, availableIDs, zeros(size(availableIDs)) ); %double the dimension every time it reach the end
                end
                availableIDs(availableIDsIdx,1) = IDrx;
                availableIDsIdx = availableIDsIdx + 1;
            end
        end
        %check the neighbors IDs
        packetUnderFocus = packets.payload{packetIdx};
        startIdx = (1 + options.ID_LENGTH_BYTE*2 + options.STATE_LENGTH_BYTE*2);
        increment = options.RSSI_LENGTH_BYTE*2+options.ID_LENGTH_BYTE*2;
        stopIdx = size(packetUnderFocus,2) - (options.BATTERY_VOLTAGE_LENGTH_BYTE*2 + options.COUNTER_LENGTH_BYTE*2);
        for idx = startIdx:increment:stopIdx
            IDtx = sscanf( packetUnderFocus(idx:idx+(options.ID_LENGTH_BYTE*2)-1) ,'%x');    %read the ID of the neighbor
            if isValidRxID(IDtx,options)
                if findID(IDtx, availableIDs) == 0 %check if the ID is already in availableIDs, if not add it
                    if availableIDsIdx == size(availableIDs,1) %resize availableIDs
                        availableIDs = cat(1, availableIDs, zeros(size(availableIDs)) ); %double the dimension every time it reach the end
                    end
                    availableIDs(availableIDsIdx,1) = IDtx;
                    availableIDsIdx = availableIDsIdx + 1;
                end
            end
        end
    elseif strcmp( packets.type(packetsIdx) ,options.GATT_TYPE_IDENTIFIER )
        % Repeat for gatt packets received through the master node - not checked for errors
        IDrx = options.MASTER_NODE_FIXED_ID; %TODO:set a value for MASTER_NODE_FIXED_ID
        if isValidRxID(IDrx,options)
            if findID(IDrx, availableIDs) == 0 %check if the ID is already in availableIDs, if not add it
                if availableIDsIdx == size(availableIDs,1) %resize availableIDs
                    availableIDs = cat(1, availableIDs, zeros(size(availableIDs)) ); %double the dimension every time it reach the end
                end
                availableIDs(availableIDsIdx,1) = IDrx;
                availableIDsIdx = availableIDsIdx + 1;
            end
        end
        packetUnderFocus = packets.payload{packetIdx};
        startIdx = 1;
        increment = options.RSSI_LENGTH_BYTE*2+options.STATE_LENGTH_BYTE*2+options.ID_LENGTH_BYTE*2;
        stopIdx = size(packets.payload{packetIdx},2);
        for idx = startIdx:increment:stopIdx
            IDtx = sscanf( packetUnderFocus(idx:idx+(options.ID_LENGTH_BYTE*2)-1) ,'%x');    %read the ID of the neighbor
            if isValidRxID(IDtx,options)
                if findID(IDtx, availableIDs) == 0 %check if the ID is already in availableIDs, if not add it
                    if availableIDsIdx == size(availableIDs,1) %resize availableIDs
                        availableIDs = cat(1, availableIDs, zeros(size(availableIDs)) ); %double the dimension every time it reach the end
                    end
                    availableIDs(availableIDsIdx,1) = IDtx;
                    availableIDsIdx = availableIDsIdx + 1;
                end
            end
        end
    end
end
availableIDs = availableIDs(1:availableIDsIdx-1,1);
%sort IDs, they will be always in the same order to make things easier
availableIDs = sort(availableIDs);

N = size(availableIDs,1);
noOfLinks = N^2; %this consider all links

%%GET THE RSSI SIGNAL FOR EACH ID PAIR
links.IDrx = cell(noOfLinks,1);
links.IDtx = cell(noOfLinks,1);
links.rawSignal.rssi = cell(noOfLinks,1);
links.rawSignal.timestamp = cell(noOfLinks,1);

for packetIdx = 1:size(packets.timestamp,1)
    if strcmp( packets.type(packetIdx), options.ADV_TYPE_IDENTIFIER )
        %get the receiver ID and its index in availableIDs
        IDrx = sscanf(packets.payload{packetIdx}(1:2),'%x'); %read the ID of the receiver (i.e. the owner of this packet)
        rxIdx = findID(IDrx, availableIDs);
        if rxIdx ~= 0
            packetUnderFocus = packets.payload{packetIdx};        
            startIdx = (1 + options.ID_LENGTH_BYTE*2 + options.STATE_LENGTH_BYTE*2);
            increment = options.RSSI_LENGTH_BYTE*2+options.ID_LENGTH_BYTE*2;
            stopIdx = size(packetUnderFocus,2) - (options.BATTERY_VOLTAGE_LENGTH_BYTE*2 + options.COUNTER_LENGTH_BYTE*2);
            for idx = startIdx:increment:stopIdx
                IDtx = sscanf( packetUnderFocus(idx:idx+(options.ID_LENGTH_BYTE*2)-1) ,'%x');    %read the ID of the neighbor
                txIdx = findID(IDtx, availableIDs);
                if txIdx ~= 0
                    linkIdx = rxIdx + (txIdx-1)*N;
                    
                    links.IDrx(linkIdx) = {IDrx}; %this is overwritten (with the same value) every time a sample for the link between IDrx and IDtx is found
                    links.IDtx(linkIdx) = {IDtx}; %this is overwritten (with the same value) every time a sample for the link between IDrx and IDtx is found
                    rssiValue = double( typecast( uint8(sscanf(packetUnderFocus(idx+(options.ID_LENGTH_BYTE*2):idx+(options.ID_LENGTH_BYTE*2)+(options.RSSI_LENGTH_BYTE*2)-1),'%x')) ,'int8') );
                    if isValidRssi(rssiValue,options)
                        links.rawSignal.rssi{linkIdx} = cat(1,links.rawSignal.rssi{linkIdx},rssiValue);
                        links.rawSignal.timestamp{linkIdx} = cat(1,links.rawSignal.timestamp{linkIdx},packets.timestamp(packetIdx));
                    end
                end
            end
            %the next is correct! it adds the IDrx and IDtx values for links where rx and tx are the same node, otherwise the IDrx and IDtx equals [] leading to possible confusion
            linkIdx = rxIdx + (rxIdx-1)*N;
            links.IDrx(linkIdx) = {IDrx};
            links.IDtx(linkIdx) = {IDrx};
        end
    elseif strcmp( packets.type(packetsIdx) ,GATT_TYPE_IDENTIFIER )
        % Repeat for gatt packets received through the master node - not checked for errors
        IDrx = MASTER_NODE_FIXED_ID;
        rxIdx = findID(IDrx, availableIDs);
        if rxIdx ~= 0
            packetUnderFocus = packets.payload{packetIdx};
            for idx = 1:RSSI_LENGTH_BYTE*2+STATE_LENGTH_BYTE*2+ID_LENGTH_BYTE*2:size(packets.payload{packetIdx},2)
                IDtx = sscanf( packetUnderFocus(idx:idx+(ID_LENGTH_BYTE*2)-1) ,'%x');    %read the ID of the neighbor
                txIdx = findID(IDtx, availableIDs);
                if txIdx ~= 0
                    linkIdx = rxIdx + (txIdx-1)*N;
                    
                    links.IDrx(linkIdx) = {IDrx}; %this is overwritten (with the same value) every time a sample for the link between IDrx and IDtx is found
                    links.IDtx(linkIdx) = {IDtx}; %this is overwritten (with the same value) every time a sample for the link between IDrx and IDtx is found
                    rssiValue = double( typecast( uint8(sscanf(packetUnderFocus(idx+(ID_LENGTH_BYTE*2):idx+(ID_LENGTH_BYTE*2)+(RSSI_LENGTH_BYTE*2)-1),'%x')) ,'int8') );
                    if isValidRssi(rssiValue)
                        links.rawSignal.rssi{linkIdx} = cat(1,links.rawSignal.rssi{linkIdx},rssiValue);
                        links.rawSignal.timestamp{linkIdx} = cat(1,links.rawSignal.timestamp{linkIdx},packets.timestamp(packetIdx));
                    end
                end
            end
            %the next is correct! it adds the IDrx and IDtx values for links where rx and tx are the same node, otherwise the IDrx and IDtx equals [] leading to possible confusion
            linkIdx = rxIdx + (rxIdx-1)*N;
            links.IDrx(linkIdx) = {IDrx};
            links.IDtx(linkIdx) = {IDrx};
        end
    end
end