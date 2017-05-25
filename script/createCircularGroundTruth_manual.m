radius = 12;
%noOfNodes = 9; 
startIdString = '0x20';
startId = sscanf(startIdString,'0x%X');

%16/05/2017
% position.xy = [ 0           , 0             ;           %0x20
%                 0           , -1             ;           %0x21
%                 -sqrt(2)/2   ,  -sqrt(2)/2    ;           %0x22
%                 -1           , 0             ;           %0x23
%                 -sqrt(2)/2   ,  sqrt(2)/2   ;           %0x24
%                 0           , 1            ;           %0x25
%                 sqrt(2)/2  , sqrt(2)/2    ;           %0x26
%                 1          , 0             ;           %0x27
%                 sqrt(2)/2  , -sqrt(2)/2    ;            %0x28
%                 ] * radius;

%23/05/2017
position.xy = [ 0           , 0             ;           %0x20
                1           , 0             ;           %0x21
                sqrt(2)/2   ,  -sqrt(2)/2    ;           %0x22
                0           , -1             ;           %0x23
                -sqrt(2)/2   ,  -sqrt(2)/2   ;           %0x24
                -1           , 0            ;           %0x25
                -sqrt(2)/2  , sqrt(2)/2    ;           %0x26
                0          , 1             ;           %0x27
                sqrt(2)/2  , sqrt(2)/2    ;            %0x28
                ] * radius;
            
noOfNodes = size(position.xy,1);
position.id = (startId:1:startId+noOfNodes-1)';         
position.orientation = zeros(noOfNodes,1);

save ../output/groundTruth_alligned_12m.mat position

position.orientation = pi*ones(noOfNodes,1);
position.orientation(1) = 0; %central node is always at orientation 0

save ../output/groundTruth_allignedInv_12m.mat position

%16/05/2017
% position.orientation = [0;
%                         2*pi*(0/8);
%                         2*pi*(1/8);
%                         2*pi*(2/8);
%                         2*pi*(3/8);
%                         2*pi*(4/8);
%                         2*pi*(5/8);
%                         2*pi*(6/8);
%                         2*pi*(7/8);
%                         ];     
%23/05/2017
position.orientation = [0;
                        2*pi*(6/8);
                        2*pi*(7/8);
                        2*pi*(0/8);
                        2*pi*(1/8);
                        2*pi*(2/8);
                        2*pi*(3/8);
                        2*pi*(4/8);
                        2*pi*(5/8);
                        ];   
                   

save ../output/groundTruth_radialInt_12m.mat position

%16/05/2017
% position.orientation = [0;
%                         2*pi*(4/8);
%                         2*pi*(5/8);
%                         2*pi*(6/8);
%                         2*pi*(7/8);
%                         2*pi*(0/8);
%                         2*pi*(1/8);
%                         2*pi*(2/8);
%                         2*pi*(3/8);
%                         ];
%23/05/2017
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

save ../output/groundTruth_radialExt_12m.mat position





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