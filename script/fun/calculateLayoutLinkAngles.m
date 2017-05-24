function [angle1, angle2] = calculateLayoutLinkAngles(layoutStruct, node1ID, node2ID, options)
    
    noOfSamples = size(layoutStruct,2);
    angle1 = zeros(noOfSamples,1);
    angle2 = zeros(noOfSamples,1);
    for sampleNo = 1:noOfSamples
        node1Idx = find(layoutStruct{sampleNo}.id == node1ID); %tx
        node2Idx = find(layoutStruct{sampleNo}.id == node2ID); %rx
            
            %calculate the distance
            xyDistance = layoutStruct{sampleNo}.xy(node1Idx,:) - layoutStruct{sampleNo}.xy(node2Idx,:);%trajectory.position.xy{txIdx} - trajectory.position.xy{rxIdx};
            txNodeOrientation = layoutStruct{sampleNo}.orientation(node1Idx,:);
            rxNodeOrientation = layoutStruct{sampleNo}.orientation(node2Idx,:);
            
            %calculate angles
            if(xyDistance(1) ~= 0)
                tang = xyDistance(2)/xyDistance(1);
                if xyDistance(1) > 0
                    angleOfArrival = atan(tang) + rxNodeOrientation;
                    angleOfDeparture = pi + atan(tang) + txNodeOrientation ;
                else
                    angleOfArrival = pi + atan(tang) + rxNodeOrientation;
                    angleOfDeparture = atan(tang) + txNodeOrientation;
                end
            else
                if xyDistance(2) > 0
                    angleOfArrival = pi/2 + rxNodeOrientation;
                    angleOfDeparture = -pi/2 + txNodeOrientation;
                else
                    angleOfArrival = -pi/2 + rxNodeOrientation;
                    angleOfDeparture = pi/2 + txNodeOrientation;
                end
            end
            
            %apply transformation to measure angles with my convention (the tangle is measured starting from y axis, the angle grows in the clockwise direction and it is always between 0 and 2*pi)
            angleOfArrival = -(angleOfArrival - pi/2);
            angleOfDeparture = -(angleOfDeparture - pi/2);
            
            angleOfArrival = double(mod(angleOfArrival,2*pi));
            angleOfArrival = (floor(angleOfArrival*1000000))/1000000;
            
            angleOfDeparture = double(mod(angleOfDeparture,2*pi));
            angleOfDeparture = (floor(angleOfDeparture*1000000))/1000000;

            angle1(sampleNo,:) = angleOfDeparture;
            angle2(sampleNo,:) = angleOfArrival;
    end
    
end