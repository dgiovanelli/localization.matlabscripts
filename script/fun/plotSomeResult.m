function plotSomeResult(file, options)

if options.VERBOSITY_LEVEL > 2
    
    warningNodified = 0;
    numberOfFigures = options.NUMBER_OF_RANOMLY_CHOSEN_FIGURE_TO_PLOT;
    if isempty(options.FILES_INDEXES_TO_PLOT)
        fileToPlot = randsample(size(file,1),1);
    else
        fileToPlot = options.FILES_INDEXES_TO_PLOT;
    end

    for fileIdxToPlot = fileToPlot
        
        if isfield(file{fileIdxToPlot},'links') %print links data
            
            links = file{fileIdxToPlot}.links;
            numberOfLinks = size(links.rawSignal.timestamp,1);
            randomlySelectedLinks = sort(randsample(numberOfLinks,numberOfFigures));
            
            if isfield(links,'rawSignal')
                for linkIdx = 1:numberOfFigures
                    linkNo = randomlySelectedLinks(linkIdx);
                    
                    t = links.rawSignal.timestamp{linkNo};
                    rssi = links.rawSignal.rssi{linkNo};
                    
                    if(size(t,2) ~= 0)
                        figure(linkIdx + 1000*fileIdxToPlot);
                        hold on;
                        plot(unixToMatlabTime(t),rssi,'o','LineWidth',2);
                        
                        datetick('x',options.DATE_FORMAT);
                        ylabel('rssi [dBm]');
                        xlabel('Time');
                        legend('Raw signal');
                        title_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x - FileNo: %d',links.IDrx{linkNo}, links.IDtx{linkNo},fileIdxToPlot);
                        axis([min(unixToMatlabTime(t)), max(unixToMatlabTime(t)),options.RSSI_AXIS_MIN_VALUE, options.RSSI_AXIS_MAX_VALUE]);
                        title(title_str);
                        grid on;
                        hold off;
                    else
                        if warningNodified == 0
                            warning('One of the selected plot contains no data.');
                            warningNodified = 1;
                        end
                    end
                end
            end
            
            if isfield(links,'windowedSignal')
                for linkIdx = 1:numberOfFigures
                    linkNo = randomlySelectedLinks(linkIdx);
                    
                    t = links.windowedSignal.timestamp{linkNo};
                    rssi = links.windowedSignal.rssi{linkNo};
                    
                    if~isempty(find(~isnan(rssi),1))
                        figure(linkIdx + 1000*fileIdxToPlot);
                        hold on;
                        plot(unixToMatlabTime(t),rssi,'LineWidth',2);
                        
                        datetick('x',options.DATE_FORMAT);
                        ylabel('rssi [dBm]');
                        xlabel('Time');
                        if isfield(links,'rawSignal')
                            legend('Raw signal','Windowed signal');
                        else
                            legend('Windowed signal');
                        end
                        title_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x - FileNo: %d',links.IDrx{linkNo}, links.IDtx{linkNo},fileIdxToPlot);
                        axis([min(unixToMatlabTime(t)), max(unixToMatlabTime(t)),options.RSSI_AXIS_MIN_VALUE, options.RSSI_AXIS_MAX_VALUE]);
                        title(title_str);
                        grid on;
                        hold off;
                    else
                        if warningNodified == 0
                            warning('One of the selected plot contains no data.');
                            warningNodified = 1;
                        end
                    end
                end
            end
            
            if isfield(links,'decimatedSignal')
                for linkIdx = 1:numberOfFigures
                    linkNo = randomlySelectedLinks(linkIdx);
                    
                    t = links.decimatedSignal.timestamp{linkNo};
                    rssi = links.decimatedSignal.rssi{linkNo};
                    
                    if~isempty(find(~isnan(rssi),1))
                        figure(linkIdx + 1000*fileIdxToPlot);
                        hold on;
                        plot(unixToMatlabTime(t),rssi,'o','LineWidth',2);
                        
                        datetick('x',options.DATE_FORMAT);
                        ylabel('rssi [dBm]');
                        xlabel('Time');
                        if isfield(links,'rawSignal') && isfield(links,'windowedSignal')
                            legend('Raw signal','Windowed signal','Decimated signal');
                        else
                            legend('Decimated signal');
                        end
                        title_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x - FileNo: %d',links.IDrx{linkNo}, links.IDtx{linkNo},fileIdxToPlot);
                        axis([min(unixToMatlabTime(t)), max(unixToMatlabTime(t)),options.RSSI_AXIS_MIN_VALUE, options.RSSI_AXIS_MAX_VALUE]);
                        title(title_str);
                        grid on;
                        hold off;
                    else
                        if warningNodified == 0
                            warning('One of the selected plot contains no data.');
                            warningNodified = 1;
                        end
                    end
                end
            end
        end
        
        if isfield(file{fileIdxToPlot},'S')
            
            S = file{fileIdxToPlot}.S;
            
            numberOfNodesToChoose = round((1+sqrt(1+8*numberOfFigures))/2);
            numberOfNodes = size(S.IDs,1);
            randomlySelectedNodes_idx = sort(randsample(numberOfNodes,numberOfNodesToChoose));
            
            t = S.timestamp;
            
            if isfield(S,'rssi')
                for rxNodeIdx = 1:numberOfNodesToChoose
                    for txNodeIdx = rxNodeIdx:numberOfNodesToChoose
                        if rxNodeIdx ~= txNodeIdx
                            txIdx = randomlySelectedNodes_idx(txNodeIdx);
                            rxIdx = randomlySelectedNodes_idx(rxNodeIdx);
                            
                            figure(100 + rxIdx+numberOfNodes*txIdx)
                            rssiDir = reshape(S.rssi(rxIdx,txIdx,:), [size(t,1),1]);
                            plot(unixToMatlabTime(t),rssiDir,'LineWidth',2);
                            hold on;
                            rssiInv = reshape(S.rssi(txIdx,rxIdx,:), [size(t,1),1]);
                            plot(unixToMatlabTime(t),rssiInv,'LineWidth',2);
                            hold off;
                            datetick('x',options.DATE_FORMAT);
                            axis([min(unixToMatlabTime(t)), max(unixToMatlabTime(t)), options.RSSI_AXIS_MIN_VALUE, options.RSSI_AXIS_MAX_VALUE]);
                            ylabel('rssi [dBm]');
                            xlabel('Time');
                            legendDir_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x', S.IDs(rxIdx), S.IDs(txIdx));
                            legendInv_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x', S.IDs(txIdx), S.IDs(rxIdx));
                            legend(legendDir_str,legendInv_str);
                            title_str = sprintf('Link simmetry - FileNo: %d',fileIdxToPlot);
                            title(title_str);
                            grid on;
                        end
                    end
                end
            end
        end
        
        if isfield(file{fileIdxToPlot},'positionMatrix')
            
            distances = file{fileIdxToPlot}.positionMatrix.valuesOfDistance;
            distances = distances(distances ~= 0);
            
            for distanceIdx = 1:size(distances,1)
                positionMatrix = file{fileIdxToPlot}.positionMatrix;
                
                %plot 1m distances (all radial links with the central node)
                
                %yToPlot = cat(1,positionMatrix.rssi{positionMatrix.valuesOfDistance == distances(distanceIdx),:,:});
                % xToPlot = positionMatrix.valuesOfDistance;
                
                %plot(yToPlot,'.')
                figure(1234*fileIdxToPlot+distanceIdx);
                hold on
                noOfAlreadyPlottedSamples = 0;
                for AoAIdx = 1 : size(positionMatrix.valuesOfAnglesOfArrivals,1)
                    for AoDIdx = 1 : size(positionMatrix.valuesOfAnglesOfDepartures,1)
                        rssiSamples = positionMatrix.rssi.value{positionMatrix.valuesOfDistance == distances(distanceIdx),AoAIdx,AoDIdx};
                        if ~isempty(rssiSamples)
                            noOfValidSamples = size(rssiSamples,1);
                            xaxis = (noOfAlreadyPlottedSamples+1:1:noOfAlreadyPlottedSamples+noOfValidSamples)';
                            plot(xaxis, rssiSamples,'.');
                            anglesText = sprintf('AoA: %.0f\nAoD: %.0f',positionMatrix.valuesOfAnglesOfArrivals(AoAIdx)*options.RAD_TO_DEF_CONST,positionMatrix.valuesOfAnglesOfDepartures(AoDIdx)*options.RAD_TO_DEF_CONST);
                            text(xaxis(round(size(xaxis,1)/2))-4,-35,anglesText,'Rotation',90,'FontWeight','bold','FontSize',8);
                            %line([noOfAlreadyPlottedSamples, noOfAlreadyPlottedSamples],[options.RSSI_AXIS_MAX_VALUE, options.RSSI_AXIS_MIN_VALUE])
                            line([noOfAlreadyPlottedSamples+noOfValidSamples, noOfAlreadyPlottedSamples+noOfValidSamples],[options.RSSI_AXIS_MAX_VALUE-5, options.RSSI_AXIS_MIN_VALUE+5],'LineStyle','-.','LineWidth',1.5,'Color','r')
                            
                            temp = positionMatrix.rssi.linksIdx{positionMatrix.valuesOfDistance == distances(distanceIdx),AoAIdx,AoDIdx};
                            i = 1;
                            while i < size(temp,1)
                                linkIdx = temp(i);
                                noOfSamples = sum(temp == linkIdx);
                                textToPlot = sprintf('IDrx: 0x%02x\nIDtx: 0x%02x',links.IDrx{linkIdx},links.IDtx{linkIdx});
                                xToPlotText = noOfAlreadyPlottedSamples + i + (noOfSamples)/2;
                                text(xToPlotText-4,-108,textToPlot,'Rotation',90,'FontWeight','bold','FontSize',8);
                                if(i + noOfSamples < size(temp,1))
                                    line([noOfAlreadyPlottedSamples+i+noOfSamples, noOfAlreadyPlottedSamples+i+noOfSamples],[rssiSamples(i+noOfSamples)-5, options.RSSI_AXIS_MIN_VALUE+10],'LineStyle','-.','LineWidth',1.5,'Color','b')
                                end
                                i = i + noOfSamples;
                            end
                            noOfAlreadyPlottedSamples = noOfAlreadyPlottedSamples + noOfValidSamples;
                        end
                    end
                end
                hold off
                axis([0, noOfAlreadyPlottedSamples,options.RSSI_AXIS_MIN_VALUE, options.RSSI_AXIS_MAX_VALUE]);
                grid on
                ylabel('RSSI [dBm]');
                xlabel('samplesNo');
                titleStr = sprintf('RSSI samples for all links with lenght %.2fm - FileNo: %d',distances(distanceIdx),fileIdxToPlot);
                title(titleStr);
            end
        end
    end
end

if options.VERBOSITY_LEVEL > 0
    noOfFiles = size(file,1);
    
    aggregatedLinksMeanStandardDeviation = zeros(noOfFiles,1);
    linksMeanStandardDeviation = zeros(noOfFiles,1);
    
    for fileIdxToPlot = 1:noOfFiles
        aggregatedLinksMeanStandardDeviation(fileIdxToPlot,1) = file{fileIdxToPlot}.S.aggregatedLinksMeanStandardDeviation;
        linksMeanStandardDeviation(fileIdxToPlot,1) = file{fileIdxToPlot}.S.linksMeanStandardDeviation;
        fprintf('File %d: linksMeanStandardDeviation = %.3f - aggregatedLinksMeanStandardDeviation = %.3f\n',fileIdxToPlot,linksMeanStandardDeviation(fileIdxToPlot,1),aggregatedLinksMeanStandardDeviation(fileIdxToPlot,1));
    end
    fprintf('Average: linksMeanStandardDeviations = %.3f - aggregatedLinksMeanStandardDeviation = %.3f\n',mean(linksMeanStandardDeviation(:,1)),mean(aggregatedLinksMeanStandardDeviation(:,1)));
end
