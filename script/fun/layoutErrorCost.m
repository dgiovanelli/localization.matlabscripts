function [Etot, grad, availableIds, energyMatrix, timestamp] = layoutErrorCost(nodesPosition, links, options)
ENABLE_HIGH_VERBOSITY_OF_MESH_RELAXATION = false;
high_precision = 0;
% if high_precision ~= 0
%     epsilon_D_energy = 0.01; %this is used when the stop condition is on the slope of energy associated to one node
%     epsilon_d_movement = 0.01;  %this is used when the stop condition is on the minimum movement of the node
%     MAX_ITER = 10000;
% else
%     epsilon_D_energy = 1; %this is used when the stop condition is on the slope of energy associated to one node
%     epsilon_d_movement = 0.1;  %this is used when the stop condition is on the minimum movement of the node
%     MAX_ITER = 2000;
% end
epsilon_D_energy = 0.2; %this is used when the stop condition is on the slope of energy associated to one node
epsilon_d_movement = 0.1;  %this is used when the stop condition is on the minimum movement of the node
MAX_ITER = 1000;

iteractions = 0;
k_spring_default = 1;

edegesLength = links.distance;
noOfLinks = size(edegesLength,2);
availableIds = unique(links.id);
nodesAmount = size(availableIds,1);
NODES_RESIDUAL_ENERGY = zeros(nodesAmount,2);

distanceMatrix = zeros(nodesAmount);
k_springs = k_spring_default*ones(nodesAmount);
dEdx = zeros(nodesAmount);
dEdy = zeros(nodesAmount);
Dm = zeros(nodesAmount,1);
if isempty(nodesPosition)
    NODE_POSITION_ID_XY = rand(nodesAmount,2)*2-1;
    r = 100*max(edegesLength(edegesLength ~= Inf)); %avoid Infs
    deltaPhi_rad = (2*pi)/nodesAmount;
    for nodeNo = 1:nodesAmount
        NODE_POSITION_ID_XY(nodeNo,:) = [r*sin(deltaPhi_rad*nodeNo), r*cos(deltaPhi_rad*nodeNo)];
    end
    MAX_ITER = MAX_ITER*2; %if the starting position is not given increase the MAX_ITER by a factor of two
else
    NODE_POSITION_ID_XY = nodesPosition;
end

Dm_max_value = Inf;
%GENERATE DISTANCE MATRIX
for linkNo = 1 : noOfLinks
    pos1 = find(availableIds == links.id(linkNo,1));
    pos2 = find(availableIds == links.id(linkNo,2));
    
    distanceMatrix(pos1, pos2) = edegesLength(linkNo);
    distanceMatrix(pos2, pos1) = edegesLength(linkNo);
    
    k_springs(pos1, pos2) = k_springs(pos1, pos2)/(edegesLength(linkNo).^2);
    k_springs(pos2, pos1) = k_springs(pos1, pos2)/(edegesLength(linkNo).^2);
    
%     k_springs(pos1, pos2) = k_springs(pos1, pos2)/unreliablility(linkNo);%sqrt(unreliablility(linkNo));
%     k_springs(pos2, pos1) = k_springs(pos2, pos1)/unreliablility(linkNo);%sqrt(unreliablility(linkNo));
    
end

% %DEPART UNCONNECTED NODES
% for nodeIdx = 1:size(distanceMatrix,1)
%     infs_line = Inf*ones(1,size(distanceMatrix,1));
%     infs_line(nodeIdx) = 0;
%     if sum(distanceMatrix(1,:) == infs_line) == size(distanceMatrix,1)
%         NODE_POSITION_ID_XY(nodeIdx,:) = [1000;1000]; %set the 1000,1000 as node position
%     end
% end
% 
E = zeros(nodesAmount,nodesAmount);
dEdx = zeros(nodesAmount,nodesAmount);
dEdy = zeros(nodesAmount,nodesAmount);
p = NODE_POSITION_ID_XY;
Etot = 0;
for nodeNo_m = 1 : nodesAmount - 1
    for nodeNo_i = nodeNo_m+1 : nodesAmount
        dmi = (p(nodeNo_m,:) - p(nodeNo_i,:));
        norm_pmi = sqrt( sum(dmi.^2, 2) );
        lmi = distanceMatrix(nodeNo_m,nodeNo_i);
        kmi = k_springs(nodeNo_m,nodeNo_i);
        
        if norm_pmi ~= Inf && norm_pmi ~= -Inf 
            E(nodeNo_m,nodeNo_i) = sign(lmi - norm_pmi)*1/2 * kmi * (lmi - norm_pmi).^2;
            E(nodeNo_i,nodeNo_m) = E(nodeNo_m,nodeNo_i);
        else
            E(nodeNo_m,nodeNo_i) = 0;
        end
        
        if  E(nodeNo_m,nodeNo_i) ~= Inf && E(nodeNo_m,nodeNo_i) ~= -Inf && ~isnan(E(nodeNo_m,nodeNo_i))
            Etot = Etot + abs(E(nodeNo_m,nodeNo_i));
        end
        
        dmi_x = dmi(1);
        dmi_y = dmi(2);
        
        dEdx(nodeNo_m,nodeNo_i) = kmi * ( dmi_x - lmi*dmi_x / norm_pmi );
        dEdx(nodeNo_i,nodeNo_m) = -dEdx(nodeNo_m,nodeNo_i);
        dEdy(nodeNo_m,nodeNo_i) = kmi * ( dmi_y - lmi*dmi_y / norm_pmi );
        dEdy(nodeNo_i,nodeNo_m) = -dEdy(nodeNo_m,nodeNo_i);
    end
end

%Etot = sum(E(~isnan(E)))/2;
dEdx(isnan(dEdx)) = 0;
dEdx(dEdx == Inf | dEdx == -Inf) = 0;
dEdy(isnan(dEdy)) = 0;
dEdy(dEdy == Inf | dEdy == -Inf) = 0;

dEdx_sum = sum(dEdx,2);
dEdy_sum = sum(dEdy,2);
grad = [dEdx_sum, dEdy_sum];
%grad = grad(:);
timestamp = links.timestamp;
energyMatrix = E;
end

