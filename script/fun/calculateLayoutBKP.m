function nodeMap = calculateLayout(links, startingPos, options)
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
if isempty(startingPos)
    NODE_POSITION_ID_XY = rand(nodesAmount,2)*2-1;
    r = 100*max(edegesLength(edegesLength ~= Inf)); %avoid Infs
    deltaPhi_rad = (2*pi)/nodesAmount;
    for nodeNo = 1:nodesAmount
        NODE_POSITION_ID_XY(nodeNo,:) = [r*sin(deltaPhi_rad*nodeNo), r*cos(deltaPhi_rad*nodeNo)];
    end
    MAX_ITER = MAX_ITER*2; %if the starting position is not given increase the MAX_ITER by a factor of two
else
    NODE_POSITION_ID_XY = startingPos;
end


if ENABLE_HIGH_VERBOSITY_OF_MESH_RELAXATION
    d = Inf;
    colorlist = hsv( MAX_ITER*nodesAmount );
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

%DEPART UNCONNECTED NODES
for nodeIdx = 1:size(distanceMatrix,1)
    infs_line = Inf*ones(1,size(distanceMatrix,1));
    infs_line(nodeIdx) = 0;
    if sum(distanceMatrix(1,:) == infs_line) == size(distanceMatrix,1)
        NODE_POSITION_ID_XY(nodeIdx,:) = [1000;1000]; %set the 1000,1000 as node position
    end
end

if ENABLE_HIGH_VERBOSITY_OF_MESH_RELAXATION
    for nodeNo=1:nodesAmount
        figure(1234);
        hold on;
        plot(NODE_POSITION_ID_XY(nodeNo,1),NODE_POSITION_ID_XY(nodeNo,2),'o','Color',colorlist((nodeNo-1)*MAX_ITER+iteractions+1,:));
        grid on;
    end
end

while Dm_max_value > epsilon_D_energy && iteractions < MAX_ITER
    %while d > epsilon_d_movement && iteractions < MAX_ITER
    for nodeNo_m = 1:nodesAmount
        for nodeNo_i = 1:nodesAmount
            
            if nodeNo_i ~= nodeNo_m
                dmi_x = NODE_POSITION_ID_XY(nodeNo_m,1) - NODE_POSITION_ID_XY(nodeNo_i,1);
                dmi_y = NODE_POSITION_ID_XY(nodeNo_m,2) - NODE_POSITION_ID_XY(nodeNo_i,2);
                
                dEdx(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_x - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_x / sqrt(dmi_x^2+dmi_y^2));
                dEdy(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_y - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_y / sqrt(dmi_x^2+dmi_y^2));
                
                
            end
        end
        dEdy_valid = dEdy(nodeNo_m,~isnan(dEdy(nodeNo_m,:)) & abs(dEdy(nodeNo_m,:)) ~= Inf);
        dEdx_valid = dEdx(nodeNo_m,~isnan(dEdx(nodeNo_m,:)) & abs(dEdx(nodeNo_m,:)) ~= Inf);
        Dm(nodeNo_m) = sqrt( (sum(dEdx_valid))^2 + (sum(dEdy_valid))^2);
    end
    
    
    [Dm_max_value, Dm_max_index] = max(Dm);
    A = zeros(2);
    B = zeros(2,1);
    
    for nodeNo_i = 1:nodesAmount
        if nodeNo_i ~= Dm_max_index
            if distanceMatrix(Dm_max_index, nodeNo_i) ~= Inf && ~isnan(distanceMatrix(Dm_max_index, nodeNo_i))
                dmi_x = NODE_POSITION_ID_XY(Dm_max_index,1) - NODE_POSITION_ID_XY(nodeNo_i,1);
                dmi_y = NODE_POSITION_ID_XY(Dm_max_index,2) - NODE_POSITION_ID_XY(nodeNo_i,2);
                dmi_x_square = dmi_x.^2;
                dmi_y_square = dmi_y.^2;
                l_mi = distanceMatrix(Dm_max_index, nodeNo_i);
                k_mi = k_springs(Dm_max_index, nodeNo_i);
                %dEdx(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_x - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_x / sqrt(dmi_x^2+dmi_y^2));
                %dEdy(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_y - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_y / sqrt(dmi_x^2+dmi_y^2));
                
                A(1,1) = A(1,1) + k_mi*( 1 - l_mi*(dmi_y_square) / ( (dmi_x_square + dmi_y_square).^(3/2) ) );
                A(1,2) = A(1,2) + l_mi*dmi_x*dmi_y / (dmi_x_square + dmi_y_square).^(3/2);
                A(2,1) = A(1,2);
                A(2,2) = A(2,2) + k_mi*( 1 - l_mi*(dmi_x_square) / (dmi_x_square + dmi_y_square).^(3/2) );
                
                B(1) = B(1) - dEdx(Dm_max_index, nodeNo_i);
                B(2) = B(2) - dEdy(Dm_max_index, nodeNo_i);
            end
        end
    end
    
    if( all(all(A)) && sum(sum(isnan(A)) == 0) && sum(sum(A > 10e+40  | A < -10e+40)) == 0 )
        if rank(A) == size(A,2)
            X = linsolve(A,B);
            dx = X(1);
            dy = X(2);
            if ENABLE_HIGH_VERBOSITY_OF_MESH_RELAXATION
                d = sqrt(dx^2 + dy^2);
                fprintf('Moving node 0x%0x to %.4f meter, Dm_max_value = %.2f.\n',availableIds(Dm_max_index),d,Dm_max_value);
            end
            NODE_POSITION_ID_XY(Dm_max_index,:) = NODE_POSITION_ID_XY(Dm_max_index,:) + 0.1*[dx,dy];
        else%move node otherwise it will block here, now move it one meter away on both axes
            NODE_POSITION_ID_XY(Dm_max_index,:) = NODE_POSITION_ID_XY(Dm_max_index,:) + [0.5,0.5];
        end
    else     %move node otherwise it will block here, now move it one meter away on both axes
        NODE_POSITION_ID_XY(Dm_max_index,:) = NODE_POSITION_ID_XY(Dm_max_index,:) + [1,1];
    end
    
    if ENABLE_HIGH_VERBOSITY_OF_MESH_RELAXATION
        for nodeNo=1:nodesAmount
            %if nodeNo == Dm_max_index
                figure(1234);
                plot(NODE_POSITION_ID_XY(nodeNo,1),NODE_POSITION_ID_XY(nodeNo,2),'o','Color',colorlist((nodeNo-1)*MAX_ITER+iteractions+1,:));
                hold on;
                grid on;
            %end
        end
        figure(1234);
        hold off;
    end
    
    iteractions = iteractions + 1;
end
%iteractions
if iteractions >= MAX_ITER
    warning('Loop stopped, MAX_ITER reached!');
end

if high_precision ~= 0
    springEnergyCost_an = @(x)springEnergyCost( x, distanceMatrix, k_springs );
    
    %USE THE FOLLOWING TWO LINES IF THE GRADIENT IS NOT PROVIDED INSIDE springEnergyCost
    %options = optimset('Display','notify');
    %[NODE_POSITION_ID_XY,~] = fminunc(springEnergyCost_an,NODE_POSITION_ID_XY,options);
    %INSTEAD USE THE FOLLOWING TWO LINES IF THE GRADIENT IS PROVIDED INSIDE springEnergyCost
    options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true,'Display','notify');
    [NODE_POSITION_ID_XY,fval] = fminunc(springEnergyCost_an,NODE_POSITION_ID_XY,options); %Providing gradient function decrease performance in some cases ....
end

%calculate springs energy
for linkNo=1:noOfLinks
    pos1 = find(availableIds == links.id(linkNo,1));
    pos2 = find(availableIds == links.id(linkNo,2));
    
    node_dist_after_loc = sqrt(sum((NODE_POSITION_ID_XY(pos1,:)-NODE_POSITION_ID_XY(pos2,:)).^2));
    if node_dist_after_loc ~= Inf && ~isnan(node_dist_after_loc)
        delta_l_spring = (distanceMatrix(pos1,pos2) - node_dist_after_loc).^2;
        
        SPRING_RESIDUAL_ENERGY(linkNo) = 1/2* k_springs(pos1,pos2) *delta_l_spring;
    end
end

%calculate the energy associated with each node
for nodeNo_1=1:nodesAmount
    
    NODES_RESIDUAL_ENERGY(nodeNo_1,1) = availableIds(nodeNo_1);
    
    for nodeNo_2=1:nodesAmount
        if nodeNo_2 ~= nodeNo_1
            linkNo = find(    (links.id(:,1) == availableIds(nodeNo_1) & links.id(:,2) == availableIds(nodeNo_2) ) | ( links.id(:,1) == availableIds(nodeNo_2) & links.id(:,2) == availableIds(nodeNo_1) )    );
            if sum(size(linkNo))==2
                if ~isnan(SPRING_RESIDUAL_ENERGY(linkNo)) && SPRING_RESIDUAL_ENERGY(linkNo) ~= Inf
                    NODES_RESIDUAL_ENERGY(nodeNo_1,2) = NODES_RESIDUAL_ENERGY(nodeNo_1,2) + SPRING_RESIDUAL_ENERGY(linkNo);
                end
            else
                warning('Link between %02f and %02f not found or doubled', availableIds(nodeNo_1), availableIds(nodeNo_2));
            end
        end
    end
end
nodeMap.id = availableIds;
nodeMap.xy = NODE_POSITION_ID_XY;
end

