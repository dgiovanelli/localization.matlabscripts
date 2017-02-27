function windowedSignal = slidingWindowAvg(rawSignal, options)

wsize = options.WSIZE_S*1000;
winc = options.WINC_S*1000;

noOfLinks = size(rawSignal.rssi,1);

windowedSignal.rssi = cell(noOfLinks,1);
windowedSignal.timestamp = cell(noOfLinks,1);

startTimestamp = min(cell2mat(rawSignal.timestamp));
endTimestamp = max(cell2mat(rawSignal.timestamp));
% windowedSignal =
for linkNo = 1:noOfLinks
    actT = startTimestamp;  %this always starts when the first packet is received so that all signals will be alligned
    %rawSignal.timestamp{linkNo}(1);
    while( actT <= endTimestamp )
        meanRssi = mean( rawSignal.rssi{linkNo}( rawSignal.timestamp{linkNo}<=actT+wsize & rawSignal.timestamp{linkNo}>=actT  ) );
        if isempty(meanRssi)
            meanRssi = NaN;
        end
        %mean of the two signals
        windowedSignal.rssi{linkNo} = cat(1, windowedSignal.rssi{linkNo}, meanRssi );
               
        actT = actT + winc;
        %timestamp (with constant dt). s
        windowedSignal.timestamp{linkNo} = cat(1, windowedSignal.timestamp{linkNo}, actT );
    end
end

