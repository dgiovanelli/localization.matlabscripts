warning('Using this script the generated date suffer from numerical precision problem!');
radius = 1;
noOfNodes = 9;
startIdString = '0x20';
startId = sscanf(startIdString,'0x%X');
firstNodeInCenter = 1;

position.xy = zeros(noOfNodes,2);
position.orientation = zeros(noOfNodes);
position.id = (startId:1:startId+noOfNodes-1)';

if firstNodeInCenter
    deltaPhi_rad = (2*pi)/(noOfNodes-1);
    firstNodeInCircleIdx = 2;
    position.xy(1,:) = [0, 0]; %put the first node in circle
else
    deltaPhi_rad = (2*pi)/(noOfNodes);
    firstNodeInCircleIdx = 1;
end

for nodeIdx = firstNodeInCircleIdx:noOfNodes
    position.xy(nodeIdx,:) = [radius*sin(deltaPhi_rad*(nodeIdx-firstNodeInCircleIdx)), radius*cos(deltaPhi_rad*(nodeIdx-firstNodeInCircleIdx))];
end

save ../output/groundTruth.mat position

% filename = '../output/groundTruthTextOut.txt';
% 
% fileID = fopen(filename,'w');
% 
% fprintf(fileID,'t,ID,xpos,ypos,orient\n');
% for nodeIdx = 1:noOfNodes
%    fprintf(fileID,'0,0x%x,%f,%f,%f\n', position.id(nodeIdx),position.xy(nodeIdx,1),position.xy(nodeIdx,2),position.orientation(nodeIdx)); 
% end

%fclose(fileID);