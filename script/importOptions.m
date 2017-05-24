%%CONSTANTS

% where are the files
% where are the files
%options.LOG_FILE_PATH = {
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.9.35.txt'; %1m alligned est
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.10.32.txt';
                      
%                      '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.11.34.txt'; %1m alligned ovest
%                      '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.12.23.txt';                      
%                       
%                      '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.13.22.txt'; %1m radialExt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.14.10.txt';
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.15.25.txt'; %1m radialInt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.16.10.txt';
%                       
%                       
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.26.30.txt'; %3m alligned est
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.27.6.txt';  
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.28.8.txt'; %3m alligned ovest
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.28.44.txt';         
%                       
%                      '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.30.1.txt'; %3m radialExt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.30.46.txt';  
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.32.2.txt'; %3m radialInt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.32.31.txt';
%                       
%                       
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.38.41.txt'; %9m alligned est
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.39.34.txt';
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.40.42.txt'; %9m alligned ovest
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.41.12.txt';
%                       
%                      '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.43.48.txt'; %9m radialExt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.44.23.txt';
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.45.32.txt'; %9m radialInt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\log_52_15.46.19.txt';
                      
%                           '..\input\LOG\log_313_16.58.35_cut.txt';
%                              '..\input\LOG\log_320_16.11.42_cut.txt';
%                      };

%options.GROUND_TRUTH_FILE_PATH =  {
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_alligned_1m.mat'; %1m alligned est
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_alligned_1m.mat';
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_allignedInv_1m.mat'; %1m alligned ovest
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_allignedInv_1m.mat';                      
%                       
%                      '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialExt_1m.mat'; %1m radialExt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialExt_1m.mat';
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialInt_1m.mat'; %1m radialInt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialInt_1m.mat';
%                       
%                       
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_alligned_3m.mat'; %3m alligned est
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_alligned_3m.mat';
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_allignedInv_3m.mat'; %3m alligned ovest
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_allignedInv_3m.mat';                      
%                       
%                      '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialExt_3m.mat'; %3m radialExt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialExt_3m.mat';
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialInt_3m.mat'; %3m radialInt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialInt_3m.mat';
%                       
%                       
%                       %'..\output\groundTruth_9m_auto.mat'; %9m alligned auto generated script
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_alligned_9m.mat'; %9m alligned est
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_alligned_9m.mat';
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_allignedInv_9m.mat'; %9m alligned ovest
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_allignedInv_9m.mat';                      
%                       
%                      '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialExt_9m.mat'; %9m radialExt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialExt_9m.mat';
%                       
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialInt_9m.mat'; %9m radialInt
%                       '..\input\LOG\MUSE_21_02_2017\LOGS\GROUND_TRUTH\groundTruth_radialInt_9m.mat';
                      
                      
%     '..\output\log_313_16.58.35.mat'
%    '..\output\log_320_16.11.42.mat'
    
%                      };

% where are the files
options.LOG_FILE_PATH = {
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_143_12.27.43.txt'; %1m alligned est
                      
                     '..\input\LOG\MUSE_16_05_2017\LOGS\log_143_12.33.2.txt'; %1m alligned ovest
                      
                     '..\input\LOG\MUSE_16_05_2017\LOGS\log_143_12.39.15.txt'; %1m radialExt
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_143_12.36.33.txt'; %1m radialInt
                      
                      
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_18.32.33.txt'; %3m alligned est
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_18.36.12.txt'; %3m alligned ovest
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_18.46.14.txt'; %3m radialExt
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_18.40.35.txt'; %3m radialInt
                      
                      
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_18.8.5.txt'; %6m alligned est
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_18.12.16.txt'; %6m alligned ovest
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_18.21.14.txt'; %6m radialExt
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_18.16.23.txt'; %6m radialInt
                                            
                      
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_17.41.52.txt'; %9m alligned est
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_17.49.43.txt'; %9m alligned ovest
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_17.59.22.txt'; %9m radialExt
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_17.54.46.txt'; %9m radialInt
                                            
                      
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_17.15.13.txt'; %12m alligned est
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_17.20.18.txt'; %12m alligned ovest
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_17.30.22.txt'; %12m radialExt
                      
                      '..\input\LOG\MUSE_16_05_2017\LOGS\log_136_17.25.23.txt'; %12m radialInt
                      
                      
                     
                      
                      
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_12.7.27.txt'; %1m alligned est
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_12.12.59.txt'; %1m alligned ovest
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_12.20.23.txt'; %1m radialExt
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_12.15.38.txt'; %1m radialInt
                      
                      
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_11.38.29.txt'; %3m alligned est
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_11.43.36.txt'; %3m alligned ovest
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_11.56.4.txt'; %3m radialExt
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_11.51.7.txt'; %3m radialInt
                      
                      
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_11.14.35.txt'; %6m alligned est
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_11.19.6.txt'; %6m alligned ovest
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_11.28.37.txt'; %6m radialExt
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_11.24.4.txt'; %6m radialInt
                                            
                      
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_10.49.19.txt'; %9m alligned est
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_10.55.12.txt'; %9m alligned ovest
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_11.2.30.txt'; %9m radialExt
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_10.58.41.txt'; %9m radialInt
                                            
                      
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_10.25.0.txt'; %12m alligned est
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_10.31.41.txt'; %12m alligned ovest
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_10.40.54.txt'; %12m radialExt
                      
                      '..\input\LOG\MUSE_23_05_2017\LOGS\log_143_10.34.58.txt'; %12m radialInt
                    };

options.GROUND_TRUTH_FILE_PATH =  {
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_alligned_1m.mat'; %1m alligned est
                      
                     '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_allignedInv_1m.mat'; %1m alligned ovest
                      
                     '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_radialExt_1m.mat'; %1m radialExt
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_radialInt_1m.mat'; %1m radialInt
                      
                      
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_alligned_3m.mat'; %3m alligned est
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_allignedInv_3m.mat'; %3m alligned ovest
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_radialExt_3m.mat'; %3m radialExt
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_radialInt_3m.mat'; %3m radialInt
                      
                      
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_alligned_6m.mat'; %6m alligned est
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_allignedInv_6m.mat'; %6m alligned ovest
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_radialExt_6m.mat'; %6m radialExt
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_radialInt_6m.mat'; %6m radialInt
                                            
                      
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_alligned_9m.mat'; %9m alligned est
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_allignedInv_9m.mat'; %9m alligned ovest
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_radialExt_9m.mat'; %9m radialExt
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_radialInt_9m.mat'; %9m radialInt
                                            
                      
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_alligned_12m.mat'; %12m alligned est
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_allignedInv_12m.mat'; %12m alligned ovest
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_radialExt_12m.mat'; %12m radialExt
                      
                      '..\input\LOG\MUSE_16_05_2017\GROUND_TRUTH\groundTruth_radialInt_12m.mat'; %12m radialInt

                      
                      
                      
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_alligned_1m.mat'; %1m alligned est
                      
                     '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_allignedInv_1m.mat'; %1m alligned ovest
                      
                     '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_radialExt_1m.mat'; %1m radialExt
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_radialInt_1m.mat'; %1m radialInt
                      
                      
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_alligned_3m.mat'; %3m alligned est
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_allignedInv_3m.mat'; %3m alligned ovest
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_radialExt_3m.mat'; %3m radialExt
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_radialInt_3m.mat'; %3m radialInt
                      
                      
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_alligned_6m.mat'; %6m alligned est
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_allignedInv_6m.mat'; %6m alligned ovest
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_radialExt_6m.mat'; %6m radialExt
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_radialInt_6m.mat'; %6m radialInt
                                            
                      
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_alligned_9m.mat'; %9m alligned est
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_allignedInv_9m.mat'; %9m alligned ovest
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_radialExt_9m.mat'; %9m radialExt
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_radialInt_9m.mat'; %9m radialInt
                                            
                      
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_alligned_12m.mat'; %12m alligned est
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_allignedInv_12m.mat'; %12m alligned ovest
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_radialExt_12m.mat'; %12m radialExt
                      
                      '..\input\LOG\MUSE_23_05_2017\GROUND_TRUTH\groundTruth_radialInt_12m.mat'; %12m radialInt
                    };

options.OUTPUT_GIF_FILEPATH = '..\output\nodeMap.gif';
                  
%used to plot data on figures axis
options.DATE_FORMAT = 'HH:MM:SS';

%packet type identifier used in the log files
options.ADV_TYPE_IDENTIFIER = 'ADV';
options.GATT_TYPE_IDENTIFIER = 'GATT';
options.TAG_TYPE_IDENTIFIER = 'TAG';

%length of fields in the ble raw packet. NB: each byte occupy two characters when converted in hex
options.ID_LENGTH_BYTE = 1;
options.STATE_LENGTH_BYTE = 1;
options.BATTERY_VOLTAGE_LENGTH_BYTE = 2;
options.COUNTER_LENGTH_BYTE = 1;
options.RSSI_LENGTH_BYTE = 1;

options.RAD_TO_DEF_CONST = 180/pi;
options.DEG_TO_RAD_CONST = 1/options.RAD_TO_DEF_CONST;

options.TRAIN_SET_LABEL_CONSTANT = 1;
options.CROSSVALIDATION_SET_LABEL_CONSTANT = 2;
options.TEST_SET_LABEL_CONSTANT = 3;

options.POLY_FADE_MODEL_LABEL_CONSTANT = 1;
options.LOG_FADE_MODEL_LABEL_CONSTANT = 2;
options.POLY2_MODEL_LABEL_CONSTANT = 3;
options.ANN_MODEL_LABEL_CONSTANT = 4;
options.ANN2_MODEL_LABEL_CONSTANT = 5;

options.ONLY_RSSI_DATA = 'onlyRssi';
options.RSSI_AND_ORIENTATION_DATA = 'rssiAndOrientation';
options.RSSI_AND_ANGLES_DATA = 'rssiAndAngles';
%% CONFIGURATION

options.WSIZE_S = 5;%3;
options.WINC_S  = 0.5;%1.5;

%the list of ids to consider. Leave it empty or comment it for consider all ids
%options.IDS_TO_CONSIDER = [32, 33 ,34 ,35 ,36 ,37];

options.FADE_MODEL_TO_USE = options.ANN2_MODEL_LABEL_CONSTANT;  % POLY_FADE_MODEL_LABEL_CONSTANT LOG_FADE_MODEL_LABEL_CONSTANT POLY2_MODEL_LABEL_CONSTANT POLY2_MODEL_LABEL_CONSTANT ANN2_MODEL_LABEL_CONSTANT
options.INPUT_DATA_TYPE = options.ONLY_RSSI_DATA;
if strcmp(options.INPUT_DATA_TYPE,options.RSSI_AND_ORIENTATION_DATA)
    warning('in this implementation angles do not add information. The overall performances degrade if this model is used!');
end
options.POLYNOMIAL_FEATURES_DEGREE = 1; %used only if FADE_MODEL_TO_USE = POLY_FADE_MODEL_LABEL_CONSTANT

options.RSSI_AXIS_MIN_VALUE = -110;
options.RSSI_AXIS_MAX_VALUE = 0;

options.VERBOSITY_LEVEL = 10;

options.NUMBER_OF_RANOMLY_CHOSEN_FIGURE_TO_PLOT = 0;

options.FILES_INDEXES_TO_PLOT = [1];%,9,17]; %set this to empty to plot only one (randomly chosen) file.

options.DECIMATION_FACTOR = 1; 

options.REGULARIZATION_LAMBDA = 0;

options.ANN_HIDDEN_LAYERS = [10];

options.LEAVE_ONE_OUT_POLICY = 0;
%0: don't use leave one out, use SETS_PARTITION_POLICY settings for splitting sets
%1: triangles based, 
%2: links based,
%3: files based
options.SETS_PARTITION_POLICY = 3;
%1: random sampling from each link
%2: test and train nodes are selected with options.TRAINING_SET_NODES_ID and options.TEST_SET_NODES_ID, and kept the same for all files
%3: divide by file with options.TRAIN_SET_FILE_IDX and options.TEST_SET_FILE_IDX
if options.SETS_PARTITION_POLICY == 2
options.TRAIN_SET_NODES_ID = [32, 33 , 34, 35 ,36, 37];
options.TEST_SET_NODES_ID = [38, 39 , 40];
options.CROSSVALIDATION_SET_NODES_ID = [38, 39 , 40];
end

if options.SETS_PARTITION_POLICY == 3
options.TRAIN_SET_FILE_IDX = 1:1:size(options.LOG_FILE_PATH,1)/2;
options.TEST_SET_FILE_IDX = size(options.LOG_FILE_PATH,1)/2+1:1:size(options.LOG_FILE_PATH,1);
options.CROSSVALIDATION_SET_FILE_IDX = options.TEST_SET_FILE_IDX;
end

options.MERGE_TEST_AND_CORSSVALIDATION = true;

options.MULTIPLE_ESTIMATION_AGGREGATION_POLICY = 2;
%1: nanmean
%2: use the most frequently predicted

options.USE_NORMALIZED_ERROR = true;

options.GIF_SPEEDUP = 10;

%% OPTIONS -- PROCESSING

if options.DECIMATION_FACTOR < 1
    error('Decimation factor shall be >= 1');
end

if size(options.FILES_INDEXES_TO_PLOT,2) > size(options.LOG_FILE_PATH,1)
    warning('size(options.FILES_INDEXES_TO_PLOT,2) > size(options.LOG_FILE_PATH,1)');
    options.FILES_INDEXES_TO_PLOT = [];
end

options.GIF_FPS = 1/(options.WINC_S)*options.GIF_SPEEDUP;