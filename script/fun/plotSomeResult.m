function plotSomeResult(arg1, arg2, arg3)

if nargin == 2
    links = arg1;
    options = arg2;
elseif nargin == 3
    links = arg1;
    S = arg2;
    options = arg3;
end

numberOfFigures = options.NUMBER_OF_RANOMLY_CHOSEN_FIGURE_TO_PLOT; %it will plot all the links between these nodes, then take the sqrt

numberOfLinks = size(links.rawSignal.timestamp,1);
randomlySelectedLinks = sort(randsample(numberOfLinks,numberOfFigures));

if isfield(links,'rawSignal') && isfield(links,'windowedSignal')
    
    for linkIdx = 1:numberOfFigures
        linkNo = randomlySelectedLinks(linkIdx);
        
        figure;
        tRaw = links.rawSignal.timestamp{linkNo};
        rssiRaw = links.rawSignal.rssi{linkNo};
        plot(unixToMatlabTime(tRaw),rssiRaw,'o','LineWidth',2);
        hold on;
        
        tWindowed = links.windowedSignal.timestamp{linkNo};
        rssiWindowed = links.windowedSignal.rssi{linkNo};
        plot(unixToMatlabTime(tWindowed),rssiWindowed,'LineWidth',2);
        hold off;
        
        datetick('x',options.DATE_FORMAT);
        ylabel('rssi [dBm]');
        xlabel('Time');
        legend('Raw samples','Windowed samples');
        title_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x',links.IDrx{linkNo}, links.IDtx{linkNo});
        title(title_str);
        grid on;
    end
    
elseif isfield(links,'rawSignal')
    
    for linkIdx = 1:numberOfFigures
        linkNo = randomlySelectedLinks(linkIdx);
        figure;
        t = links.rawSignal.timestamp{linkNo};
        rssi = links.rawSignal.rssi{linkNo};
        plot(unixToMatlabTime(t),rssi,'o','LineWidth',2);
        datetick('x',options.DATE_FORMAT);
        ylabel('rssi [dBm]');
        xlabel('Time');
        legend('Raw samples');
        title_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x',links.IDrx{linkNo}, links.IDtx{linkNo});
        title(title_str);
        grid on;
    end
    
end

if(exist('S','var'))
    
    numberOfNodesToChoose = round((1+sqrt(1+8*numberOfFigures))/2);
    
    numberOfNodes = size(S.IDs,1);
    randomlySelectedNodes_idx = sort(randsample(numberOfNodes,numberOfNodesToChoose));
    
    t = S.timestamp;
    
    for rxNodeIdx = 1:numberOfNodesToChoose
        for txNodeIdx = rxNodeIdx:numberOfNodesToChoose
            if rxNodeIdx ~= txNodeIdx
                txIdx = randomlySelectedNodes_idx(txNodeIdx);
                rxIdx = randomlySelectedNodes_idx(rxNodeIdx);
                
                figure
                rssiDir = reshape(S.rssi(rxIdx,txIdx,:), [size(t,1),1]);
                plot(t,rssiDir,'LineWidth',2);
                hold on;
                rssiInv = reshape(S.rssi(txIdx,rxIdx,:), [size(t,1),1]);
                plot(t,rssiInv,'LineWidth',2);
                hold off;
                
                legendDir_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x', S.IDs(rxIdx), S.IDs(txIdx));
                legendInv_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x', S.IDs(txIdx), S.IDs(rxIdx));
                legend(legendDir_str,legendInv_str);
                %             title_str = sprintf('IDrx: 0x%02x, IDtx: 0x%02x',links.IDrx{linkNo}, links.IDtx{linkNo});
                %             title(title_str);
                grid on;
            end
        end
    end
end