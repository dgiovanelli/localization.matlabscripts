function plotNodesLayout(file, options,layoutNo)
if layoutNo < 1 || layoutNo > size(file{1}.layout,2)
    error('Not valid value for layoutNo, number of available layouts: %d',size(file{1}.layout,2));
end
squareSize = 20;
warning('off','MATLAB:handle_graphics:exceptions:SceneNode');

noOfFile = size(file,1);
nodeMinEnergy = 0; % 0.002
nodeMaxEnergy = 0.6; % 0.553
linkMinEnergy = 0; % 0.002
linkMaxEnergy = 0.1; % 0.553
noOfEnergyBins = 256;
nodeEnergyBins = nodeMinEnergy:(nodeMaxEnergy-nodeMinEnergy)/noOfEnergyBins:nodeMaxEnergy-(nodeMaxEnergy-nodeMinEnergy)/noOfEnergyBins;
linkEnergyBins = linkMinEnergy:(linkMaxEnergy-linkMinEnergy)/noOfEnergyBins:linkMaxEnergy-(linkMaxEnergy-linkMinEnergy)/noOfEnergyBins;
nodeEnergyColorlist = hsv( noOfEnergyBins*4 );
linkEnergyColorlist = hsv( noOfEnergyBins*4 );
%define a function for draw arrows
%drawArrow = @(x,y) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0 );   

for fileIdx = 1 : noOfFile
    noOfSamples = size(file{fileIdx}.layout{layoutNo},2);
    for sampleNo = 1 : noOfSamples
        h=figure(1);
        hold off;
        set(get(h,'Children'),'HitTest','off');
        x = file{fileIdx}.layout{layoutNo}{sampleNo}.xy(:,1);
        y = file{fileIdx}.layout{layoutNo}{sampleNo}.xy(:,2);
        x0 = mean(file{fileIdx}.layout{layoutNo}{sampleNo}.xy(:,1));
        y0 = mean(file{fileIdx}.layout{layoutNo}{sampleNo}.xy(:,2));
        xt = x-x0;
        yt = y-y0;

        nodesEnergy = sum(abs(file{fileIdx}.layout{layoutNo}{sampleNo}.energyMatrix))';
        
        noOfNodes = size(file{fileIdx}.layout{layoutNo}{sampleNo}.id,1);
        for nodeNo = 1:noOfNodes
            nodeEnergy = nodesEnergy(nodeNo,1);
            [~, idx] = min(abs(nodeEnergy - nodeEnergyBins));
            binNo = noOfEnergyBins + 1 - idx;
            plot(xt(nodeNo,1),yt(nodeNo,1),'o','lineWidth',3,'Color',nodeEnergyColorlist(binNo,:));
            hold on
            p1 = [xt(nodeNo,1), yt(nodeNo,1)];
            nodeOrientation = file{fileIdx}.layout{layoutNo}{sampleNo}.orientation(nodeNo,1);
            p2 = [xt(nodeNo,1)+sin(nodeOrientation), yt(nodeNo,1)+cos(nodeOrientation)]; %TODO: CALCULATE THIS BASED ON ORIENTATION DATA
            dp = p2-p1;
%             quiver(p1(1),p1(2),dp(1),dp(2),0,'lineWidth',2, 'Color', [0,0,0]);
            str = sprintf('0x%02X', file{fileIdx}.layout{layoutNo}{sampleNo}.id(nodeNo));
            text(xt(nodeNo,1)+squareSize/100,yt(nodeNo,1) ,str,'FontSize',6,'FontWeight','bold');
            for nodeToLinkNo = 1:noOfNodes
                if nodeToLinkNo ~= nodeNo
                    linkStartxy = [xt(nodeNo); yt(nodeNo)];
                    linkStopxy = [xt(nodeToLinkNo); yt(nodeToLinkNo)];
                    linkEn = file{fileIdx}.layout{layoutNo}{sampleNo}.energyMatrix(nodeNo, nodeToLinkNo);
                    [~, idx] = min(abs(abs(linkEn) - linkEnergyBins));
                    if(idx > noOfEnergyBins/3) 
                        binNo = noOfEnergyBins + 1 - idx;
                        if linkEn < 0
                            line([linkStartxy(1,1),linkStopxy(1,1)],[linkStartxy(2,1),linkStopxy(2,1)],'Color',linkEnergyColorlist(binNo,:),'LineStyle','-');
                        else
                            line([linkStartxy(1,1),linkStopxy(1,1)],[linkStartxy(2,1),linkStopxy(2,1)],'Color',linkEnergyColorlist(binNo,:),'LineStyle',':');
                        end
                    end
                    if nodeEnergy > 1/2*nodeMaxEnergy && abs(linkEn) > 3/4 * linkMaxEnergy
                        %fprintf('%s - Bad linkDetected! Node id: 0x%02X, link with 0x%02X.\n',datetime(unixToMatlabTime(file{fileIdx}.layout{layoutNo}{sampleNo}.timestamp),'ConvertFrom','datenum', 'Format','HH:mm:ss'),file{fileIdx}.layout{layoutNo}{sampleNo}.id(nodeNo),file{fileIdx}.layout{layoutNo}{sampleNo}.id(nodeToLinkNo));
                    end
                end
            end
        end
        str = sprintf('File: %d/%d - %s',fileIdx, noOfFile, datetime(unixToMatlabTime(file{fileIdx}.layout{layoutNo}{sampleNo}.timestamp),'ConvertFrom','datenum', 'Format','HH:mm:ss'));
        text(-squareSize/2 + squareSize/20,squareSize/2 - squareSize/20 ,str,'FontSize',14,'FontWeight','bold');
        set(h, 'Position', [15 40 750 640])
        axis([-squareSize/2 squareSize/2 -squareSize/2 squareSize/2]);
        grid on
        
        line([-squareSize/2*0.9, -squareSize/2*0.8], [squareSize/2*0.6, squareSize/2*0.7],'Color',linkEnergyColorlist(noOfEnergyBins + 1,:),'LineStyle','-', 'LineWidth',2);
        text(-squareSize/2*0.8, squareSize/2*0.65 ,'Attractive force','FontSize',14,'FontWeight','bold');
        line([-squareSize/2*0.9, -squareSize/2*0.8], [squareSize/2*0.7, squareSize/2*0.8],'Color',linkEnergyColorlist(noOfEnergyBins + 1,:),'LineStyle',':', 'LineWidth',2);
        text(-squareSize/2*0.8, squareSize/2*0.75 ,'Repulsive force','FontSize',14,'FontWeight','bold');
        
        title(options.OUTPUT_GIF_FILEPATH);
        
        drawnow
        frame = getframe(1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256,'nodither');
        if sampleNo == 1 && fileIdx == 1
            imwrite(imind,cm,options.OUTPUT_GIF_FILEPATH,'gif', 'Loopcount',Inf,'delaytime',1/options.GIF_FPS);
        else
            imwrite(imind,cm,options.OUTPUT_GIF_FILEPATH,'gif','WriteMode','append','delaytime',1/options.GIF_FPS);
        end
    end
end
