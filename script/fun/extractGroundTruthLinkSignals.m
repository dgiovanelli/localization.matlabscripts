function groundTruthLinks = extractGroundTruthLinkSignals(positions,links,options)

availableIDs = zeros(5,1);
availableIDsIdx = 1;

for positionIdx = 1:size(positions.timestamp,1)
    ID = positions.id(positionIdx);
    if isValidRxID(ID,options)
        if findID(ID, availableIDs) == 0 %check if the ID is already in availableIDs, if not add it
            if availableIDsIdx == size(availableIDs,1) %resize availableIDs
                availableIDs = cat(1, availableIDs, zeros(size(availableIDs)) ); %double the dimension every time it reach the end
            end
            availableIDs(availableIDsIdx,1) = ID;
            availableIDsIdx = availableIDsIdx + 1;
        end
    end
end

availableIDs = availableIDs(1:availableIDsIdx-1,1);
%sort IDs, they will be always in the same order to make things easier
availableIDs = sort(availableIDs);

N = size(availableIDs,1);

trajectory.ID = cell(N,1);
trajectory.position.xy = cell(N,1);
trajectory.position.orientation = cell(N,1);
trajectory.position.timestamp = cell(N,1);

for positionIdx = 1:size(positions.timestamp,1)
    ID = positions.id(positionIdx);
    idIdx = findID(ID, availableIDs);
    if idIdx ~= 0
        trajectory.ID{idIdx} = ID;
        trajectory.position.xy{idIdx} = cat(1,trajectory.position.xy{idIdx},positions.xy(positionIdx,:));
        trajectory.position.timestamp{idIdx} = cat(1,trajectory.position.timestamp{idIdx},positions.timestamp(positionIdx));
        trajectory.position.orientation{idIdx} = cat(1,trajectory.position.orientation{idIdx},positions.orientation(positionIdx));
    end
end

noOfLinks = N^2; %this consider all links

groundTruthLinks.IDrx = cell(noOfLinks,1);
groundTruthLinks.IDtx = cell(noOfLinks,1);
groundTruthLinks.referenceSignal.distance = cell(noOfLinks,1);
groundTruthLinks.referenceSignal.angleOfArrival = cell(noOfLinks,1);
groundTruthLinks.referenceSignal.angleOfDeparture = cell(noOfLinks,1);
groundTruthLinks.referenceSignal.timestamp = cell(noOfLinks,1);

acquiredLinks = cell2mat([links.IDrx, links.IDtx]);


for rxIdx = 1 : N
    for txIdx = 1 : N
        IDrx = trajectory.ID{rxIdx};
        IDtx = trajectory.ID{txIdx};
        
        %linkIdx = rxIdx + (txIdx-1)*N;
        linkIdx = find((acquiredLinks(:,1) == IDrx) & (acquiredLinks(:,2) == IDtx)); %using this the acquired and reference data will be both ordered
        if sum(size(linkIdx)) ~= 2
            error('The same link is missing or appears more than one in links variable');
        end
        groundTruthLinks.IDrx{linkIdx} = IDrx;
        groundTruthLinks.IDtx{linkIdx} = IDtx;
        
        if size(trajectory.position.timestamp{rxIdx},1) && size(trajectory.position.timestamp{txIdx},1) %if both nodes have only one position they are fixed nodes
            
            xyDistance = trajectory.position.xy{txIdx} - trajectory.position.xy{rxIdx};
            distance = sqrt(xyDistance(1)^2+xyDistance(2)^2);
            
            angleOfArrival = atan(xyDistance(1)/xyDistance(2)) - trajectory.position.orientation{rxIdx};
            angleOfArrival = mod(angleOfArrival,2*pi);
            
            angleOfDeparture = atan(xyDistance(1)/xyDistance(2)) - trajectory.position.orientation{txIdx} + pi;
            angleOfDeparture = mod(angleOfDeparture,2*pi);
            
            groundTruthLinks.referenceSignal.timestamp{linkIdx} = links.windowedSignal.timestamp{linkIdx};
            groundTruthLinks.referenceSignal.distance{linkIdx} = distance*ones(size(groundTruthLinks.referenceSignal.timestamp{linkIdx}));
            groundTruthLinks.referenceSignal.angleOfArrival{linkIdx} = angleOfArrival*ones(size(groundTruthLinks.referenceSignal.timestamp{linkIdx}));
            groundTruthLinks.referenceSignal.angleOfDeparture{linkIdx} = angleOfDeparture*ones(size(groundTruthLinks.referenceSignal.timestamp{linkIdx}));
        else %one of the two nodes have more than one position in the ground truth trajectory
            error('Mobile nodes are not supprted for now!');
        end
    end
end


