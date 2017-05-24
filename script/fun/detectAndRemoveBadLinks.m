function features = detectAndRemoveBadLinks(file,options,layoutNo)
if layoutNo < 1 || layoutNo > size(file{1}.layout,2)
    error('Not valid value for layoutNo, number of available layouts: %d',size(file{1}.layout,2));
end
    
if size(file,1) > 1
    error('detectAndRemoveBadLinks(__) still does not support multiple files!');
end

noOfFile = size(file,1);
nodeMinEnergy = 0; % 0.002
nodeMaxEnergy = 0.6; % 0.553
linkMinEnergy = 0; % 0.002
linkMaxEnergy = 0.1; % 0.553
for fileIdx = 1 : noOfFile
    noOfSamples = size(file{fileIdx}.layout{layoutNo},1);
    features = file{fileIdx}.features;
    for sampleNo = 1 : noOfSamples
        nodesEnergy = sum(abs(file{fileIdx}.layout{layoutNo}{sampleNo}.energyMatrix))';
        noOfNodes = size(file{fileIdx}.layout{layoutNo}{sampleNo}.id,1);
        for nodeNo = 1:noOfNodes
            nodeEnergy = nodesEnergy(nodeNo,1);
            for nodeToLinkNo = 1:noOfNodes
                if nodeToLinkNo ~= nodeNo
                    linkEn = abs(file{fileIdx}.layout{layoutNo}{sampleNo}.energyMatrix(nodeNo, nodeToLinkNo));
                    if nodeEnergy > 0.75*nodeMaxEnergy && linkEn > 0.75*linkMaxEnergy
                        linkNo = (cell2mat(file{fileIdx}.features.ID1) == file{fileIdx}.layout{layoutNo}{sampleNo}.id(nodeNo) & cell2mat(file{fileIdx}.features.ID2) == file{fileIdx}.layout{layoutNo}{sampleNo}.id(nodeToLinkNo)) | (cell2mat(file{fileIdx}.features.ID2) == file{fileIdx}.layout{layoutNo}{sampleNo}.id(nodeNo) & cell2mat(file{fileIdx}.features.ID1) == file{fileIdx}.layout{layoutNo}{sampleNo}.id(nodeToLinkNo));
                        features.X.rssi{linkNo}(sampleNo) = NaN;
                        fprintf('File: %d, %s - Bad linkDetected! Node id: 0x%02X, link with 0x%02X.\n',file{fileIdx}.fileIdx,datetime(unixToMatlabTime(file{fileIdx}.layout{layoutNo}{sampleNo}.timestamp),'ConvertFrom','datenum', 'Format','HH:mm:ss'),file{fileIdx}.layout{layoutNo}{sampleNo}.id(nodeNo),file{fileIdx}.layout{layoutNo}{sampleNo}.id(nodeToLinkNo));
                    end
                end
            end
        end
    end
end

end
