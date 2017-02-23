function links = extractLinkSignals(packets)
%length of fields in the ble raw packet. NB: each byte occupy two characters when converted in hex
ID_LENGTH_BYTE = 1;
STATE_LENGTH_BYTE = 1;
BATTERY_VOLTAGE_LENGTH_BYTE = 2;
COUNTER_LENGTH_BYTE = 1;
RSSI_LENGTH_BYTE = 1;

ADV_TYPE_IDENTIFIER = 'ADV';
GATT_TYPE_IDENTIFIER = 'GATT';

%%DISCOVER ALL IDS
availableIDs = zeros(5,1);
availableIDsIdx = 1;
for packetIdx = 1:size(packets.timestamp,1)
    if strcmp( packets.type(packetIdx) ,ADV_TYPE_IDENTIFIER )
        %check the receiver ID
        IDrx = sscanf(packets.payload{packetIdx}(1:2),'%x'); %read the ID of the receiver (i.e. the owner of this packet)
        if isValidRxID(IDrx)
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
        for idx = (1 + ID_LENGTH_BYTE*2 + STATE_LENGTH_BYTE*2):RSSI_LENGTH_BYTE*2+ID_LENGTH_BYTE*2:size(packetUnderFocus,2) - (BATTERY_VOLTAGE_LENGTH_BYTE*2 + COUNTER_LENGTH_BYTE*2)
            IDtx = sscanf( packetUnderFocus(idx:idx+(ID_LENGTH_BYTE*2)-1) ,'%x');    %read the ID of the neighbor
            if findID(IDtx, availableIDs) == 0 %check if the ID is already in availableIDs, if not add it
                if availableIDsIdx == size(availableIDs,1) %resize availableIDs
                    availableIDs = cat(1, availableIDs, zeros(size(availableIDs)) ); %double the dimension every time it reach the end
                end
                availableIDs(availableIDsIdx,1) = IDtx;
                availableIDsIdx = availableIDsIdx + 1;
            end
        end
    elseif strcmp( packets.type(packetsIdx) ,GATT_TYPE_IDENTIFIER )
        %check the neighbors IDs - not checked for errors
        packetUnderFocus = packets.payload{packetIdx};
        for idx = 1:RSSI_LENGTH_BYTE*2+STATE_LENGTH_BYTE*2+ID_LENGTH_BYTE*2:size(packets.payload{packetIdx},2)
            IDtx = sscanf( packetUnderFocus(idx:idx+(ID_LENGTH_BYTE*2)-1) ,'%x');    %read the ID of the neighbor
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
availableIDs = availableIDs(1:availableIDsIdx-1,1);

N = size(availableIDs,1);
noOfLinks = N^2; %this consider all links

%%GET THE RSSI SIGNAL FOR EACH ID PAIR
links.IDrx = zeros(noOfLinks,1);
links.IDtx = zeros(noOfLinks,1);
links.rssiSignal = cell(noOfLinks,1);
links.timestamp = cell(noOfLinks,1);

for packetIdx = 1:size(packets.timestamp,1)
    if strcmp( packets.type(packetIdx) ,ADV_TYPE_IDENTIFIER )
        %get the receiver ID and its index in availableIDs
        IDrx = sscanf(packets.payload{packetIdx}(1:2),'%x'); %read the ID of the receiver (i.e. the owner of this packet)
        rxIdx = findID(IDrx, availableIDs);     
        packetUnderFocus = packets.payload{packetIdx};
        for idx = (1 + ID_LENGTH_BYTE*2 + STATE_LENGTH_BYTE*2):RSSI_LENGTH_BYTE*2+ID_LENGTH_BYTE*2:size(packetUnderFocus,2) - (BATTERY_VOLTAGE_LENGTH_BYTE*2 + COUNTER_LENGTH_BYTE*2)
            IDtx = sscanf( packetUnderFocus(idx:idx+(ID_LENGTH_BYTE*2)-1) ,'%x');    %read the ID of the neighbor
            txIdx = findID(IDtx, availableIDs);
            linkIdx = rxIdx + (txIdx-1)*N;
            
            links.IDrx(linkIdx) = IDrx; %this is overwritten (with the same value) every time a sample for the link between IDrx and IDtx is found
            links.IDtx(linkIdx) = IDtx; %this is overwritten (with the same value) every time a sample for the link between IDrx and IDtx is found
            rssiValue = double( typecast( uint8(sscanf(packetUnderFocus(idx+(ID_LENGTH_BYTE*2):idx+(ID_LENGTH_BYTE*2)+(RSSI_LENGTH_BYTE*2)-1),'%x')) ,'int8') );
            links.rssiSignal{linkIdx} = cat(1,links.rssiSignal{linkIdx},rssiValue);
            links.timestamp{linkIdx} = cat(1,links.timestamp{linkIdx},packets.timestamp(packetIdx));
            if findID(IDtx, availableIDs) == 0 %check if the ID is already in availableIDs, if not add it
                if availableIDsIdx == size(availableIDs,1) %resize availableIDs
                    availableIDs = cat(1, availableIDs, zeros(size(availableIDs)) ); %double the dimension every time it reach the end
                end
                availableIDs(availableIDsIdx,1) = IDtx;
                availableIDsIdx = availableIDsIdx + 1;
            end
        end
    elseif strcmp( packets.type(packetsIdx) ,GATT_TYPE_IDENTIFIER )
%         %check the neighbors IDs - not checked for errors
%         packetUnderFocus = packets.payload{packetIdx};
%         for idx = 1:RSSI_LENGTH_BYTE*2+STATE_LENGTH_BYTE*2+ID_LENGTH_BYTE*2:size(packets.payload{packetIdx},2)
%             IDtx = sscanf( packetUnderFocus(idx:idx+(ID_LENGTH_BYTE*2)-1) ,'%x');    %read the ID of the neighbor
%             if findID(IDtx, availableIDs) == 0 %check if the ID is already in availableIDs, if not add it
%                 if availableIDsIdx == size(availableIDs,1) %resize availableIDs
%                     availableIDs = cat(1, availableIDs, zeros(size(availableIDs)) ); %double the dimension every time it reach the end
%                 end
%                 availableIDs(availableIDsIdx,1) = IDtx;
%                 availableIDsIdx = availableIDsIdx + 1;
%             end
%         end
    end
end