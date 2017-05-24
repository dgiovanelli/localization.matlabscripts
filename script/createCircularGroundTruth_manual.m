radius = 1;
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

save ../output/groundTruth_alligned_1m.mat position

position.orientation = pi*ones(noOfNodes,1);
position.orientation(1) = 0; %central node is always at orientation 0

save ../output/groundTruth_allignedInv_1m.mat position

position.orientation = [0;
                        2*pi*(6/8);
                        2*pi*(1/8);
                        2*pi*(0/8);
                        2*pi*(1/8);
                        2*pi*(2/8);
                        2*pi*(3/8);
                        2*pi*(4/8);
                        2*pi*(5/8);
                        ];                        

save ../output/groundTruth_radialInt_1m.mat position

position.orientation = [0;
                        2*pi*(2/8);
                        2*pi*(3/8);
                        2*pi*(4/8);
                        2*pi*(5/8);
                        2*pi*(6/8);
                        2*pi*(7/8);
                        2*pi*(0/8);
                        2*pi*(1/8);
                        ];

save ../output/groundTruth_radialExt_1m.mat position





% position.xy = [ -3          , 1             ; 
%                 -2          , 1             ;
%                 -1          , 1             ;
%                 0           , 1             ;
%                 -3          , 0             ; 
%                 -2          , 0             ;
%                 -1          , 0             ;
%                 0           , 0             ;
%                 15          , -1    ;
%                 ];
% noOfNodes = size(position.xy,1);     
% position.orientation = zeros(noOfNodes,1);
% position.id = (startId:1:startId+noOfNodes-1)';   
% 
% save ../output/log_313_16.58.35.mat position
% 
% 
% 
% 
% position.xy = [ -3          , 1             ; 
%                 -2          , 1             ;
%                 -1          , 1             ;
%                 0           , 1             ;
%                 -3          , 0             ; 
%                 -2          , 0             ;
%                 -1          , 0             ;
%                 0           , 0             ;
%                 15          , 0.5    ;
%                 14.5          , 0.5    ;
%                 ];
% noOfNodes = size(position.xy,1);            
% position.orientation = zeros(noOfNodes,1);
% position.id = (startId:1:startId+noOfNodes-1)';   
% 
% save ../output/log_320_16.11.42.mat position