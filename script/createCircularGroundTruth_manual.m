radius = 9;
%noOfNodes = 9; 
startIdString = '0x20';
startId = sscanf(startIdString,'0x%X');

position.xy = [ 0           , 0             ; 
                0           , 1             ;
                sqrt(2)/2   ,  sqrt(2)/2    ;
                1           , 0             ;
                sqrt(2)/2   ,  -sqrt(2)/2   ;
                0           , -1            ;
                -sqrt(2)/2  , -sqrt(2)/2    ;
                -1          , 0             ;
                -sqrt(2)/2  , sqrt(2)/2    ;
                ] * radius;

noOfNodes = size(position.xy,1);
position.id = (startId:1:startId+noOfNodes-1)';         
position.orientation = zeros(noOfNodes,1);

save ../output/groundTruth_alligned.mat position

position.orientation = pi*ones(noOfNodes,1);
position.orientation(1) = 0; %central node is always at orientation 0

save ../output/groundTruth_allignedInv.mat position

position.orientation = [0;
                        2*pi*(4/8);
                        2*pi*(5/8);
                        2*pi*(6/8);
                        2*pi*(7/8);
                        2*pi*(8/8);
                        2*pi*(1/8);
                        2*pi*(2/8);
                        2*pi*(3/8);
                        ];
                        

save ../output/groundTruth_radialInt.mat position

position.orientation = [0;
                        2*pi*(0/8);
                        2*pi*(1/8);
                        2*pi*(2/8);
                        2*pi*(3/8);
                        2*pi*(4/8);
                        2*pi*(5/8);
                        2*pi*(6/8);
                        2*pi*(7/8);
                        ];

save ../output/groundTruth_radialExt.mat position