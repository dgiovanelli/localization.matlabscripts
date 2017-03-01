function plotSomeResult(file, options)

if options.VERBOSITY_LEVEL > 2
    
    warningNodified = 0;
    numberOfFigures = options.NUMBER_OF_RANOMLY_CHOSEN_FIGURE_TO_PLOT;
    noOfFiles = size(file,1);
    for fileIdxToPlot = 1:noOfFiles
        
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
                        axis([min(unixToMatlabTime(t)), max(unixToMatlabTime(t)), -100, -10]);
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
                        axis([min(unixToMatlabTime(t)), max(unixToMatlabTime(t)), -100, -10]);
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
                        axis([min(unixToMatlabTime(t)), max(unixToMatlabTime(t)), -100, -10]);
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
                            axis([min(unixToMatlabTime(t)), max(unixToMatlabTime(t)), -100, -10]);
                            ylabel('rssi [dBm]');
                            xlabel('Time');
                            legendDir_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x', S.IDs(rxIdx), S.IDs(txIdx));
                            legendInv_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x', S.IDs(txIdx), S.IDs(rxIdx));
                            legend(legendDir_str,legendInv_str);
                            title_str = sprintf('Link simmetry - FileNo: %d',links.IDrx{linkNo}, links.IDtx{linkNo},fileIdxToPlot);
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
                yToPlot = cat(1,positionMatrix.rssi{positionMatrix.valuesOfDistance == distances(distanceIdx),:,:});
                % xToPlot = positionMatrix.valuesOfDistance;
                figure;
                plot(yToPlot,'.')
                axis([0, size(yToPlot,1), -100, -10]);
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
