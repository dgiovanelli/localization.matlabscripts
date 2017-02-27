function [packets, tags] = extractPacketsFromFile(fileID,options)

%% Format string for each line of text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%f%f%f%f%s%s%s%s%s%[^\n\r]';
delimiter = ' ';

%% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

year = dataArray{:, 1};
month = dataArray{:, 2};
date = dataArray{:, 3};
hour = dataArray{:, 4};
minutes = dataArray{:, 5};
seconds = dataArray{:, 6};
ticks = dataArray{:, 7};
source_mac = dataArray{:, 8};
source_ble_name = dataArray{:, 9};
data_type = dataArray{:, 10};
packet_rssi = dataArray{:, 11};
packet_payload = dataArray{:, 12};

packets.timestamp = zeros(size(year,1),1);
packets.payload = cell(size(year,1),1);
packets.type = cell(size(year,1),1);

tags.timestamp = zeros(size(year,1),1);
tags.payload = cell(size(year,1),1);
tags.type = cell(size(year,1),1);

packetsIdx = 1; % this index is increased only if the data_type is of a used type
tagIdx = 1; % this index is increased only if the data_type is of a used type
for packetNo = 1:size(year,1)
    if strcmp(data_type(packetNo),options.ADV_TYPE_IDENTIFIER) || strcmp(data_type(packetNo),options.GATT_TYPE_IDENTIFIER)
        packets.timestamp(packetsIdx) = ticks(packetNo);
        packets.payload(packetsIdx) = packet_payload(packetNo);
        packets.type(packetsIdx) = data_type(packetNo);
        packetsIdx = packetsIdx + 1;
    elseif strcmp(data_type(packetNo),options.TAG_TYPE_IDENTIFIER)
        tags.timestamp(tagIdx) = ticks(packetNo);
        tags.payload(tagIdx) = packet_payload(packetNo);
        tags.type(tagIdx) = data_type(packetNo);
        tagIdx = tagIdx + 1;
    end
end
packets.timestamp = packets.timestamp(1:packetsIdx-1);
packets.payload = packets.payload(1:packetsIdx-1);
packets.type = packets.type(1:packetsIdx-1);

tags.timestamp = tags.timestamp(1:tagIdx-1);
tags.payload = tags.payload(1:tagIdx-1);
tags.type = tags.type(1:tagIdx-1);

