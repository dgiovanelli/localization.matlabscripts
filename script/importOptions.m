%%CONSTANTS

% where are the files
options.LOG_FILE_PATH = {
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.9.35.txt'; %1m alligned
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.10.32.txt';
                      
                     '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.11.34.txt'; %1m allignedInv
                     '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.12.23.txt';                      
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.13.22.txt'; %1m radialExt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.14.10.txt';
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.15.25.txt'; %1m radialInt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.16.10.txt';
                      
                      
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.26.30.txt'; %3m alligned
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.27.6.txt';  
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.28.8.txt'; %3m allignedInv
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.28.44.txt';         
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.30.1.txt'; %3m radialExt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.30.46.txt';  
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.32.2.txt'; %3m radialInt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.32.31.txt';
                      
                      
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.38.41.txt'; %9m alligned
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.39.34.txt';
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.40.42.txt'; %9m allignedInv
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.41.12.txt';
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.43.48.txt'; %9m radialExt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.44.23.txt';
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.45.32.txt'; %9m radialInt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\log_52_15.46.19.txt';
                      };

options.GROUND_TRUTH_FILE_PATH =  {
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_alligned_1m.mat'; %1m alligned
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_alligned_1m.mat';
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_allignedInv_1m.mat'; %1m allignedInv
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_allignedInv_1m.mat';                      
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialExt_1m.mat'; %1m radialExt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialExt_1m.mat';
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialInt_1m.mat'; %1m radialInt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialInt_1m.mat';
                      
                      
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_alligned_3m.mat'; %3m alligned
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_alligned_3m.mat';
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_allignedInv_3m.mat'; %3m allignedInv
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_allignedInv_3m.mat';                      
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialExt_3m.mat'; %3m radialExt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialExt_3m.mat';
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialInt_3m.mat'; %3m radialInt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialInt_3m.mat';
                      
                      
                      %'..\output\groundTruth_9m_auto.mat'; %9m alligned auto generated script
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_alligned_9m.mat'; %9m alligned
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_alligned_9m.mat';
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_allignedInv_9m.mat'; %9m allignedInv
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_allignedInv_9m.mat';                      
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialExt_9m.mat'; %9m radialExt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialExt_9m.mat';
                      
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialInt_9m.mat'; %9m radialInt
                      '..\input\LOG\MUSE_21_02_2016\LOGS\GROUND_TRUTH\groundTruth_radialInt_9m.mat';
                      };
                  
                  
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

%the list of ids to consider. Leave it empty or comment it for consider all ids
%options.IDS_TO_CONSIDER = [32, 33 ,35,37,39];

options.RAD_TO_DEF_CONST = 180/pi;
options.DEG_TO_RAD_CONST = 1/options.RAD_TO_DEF_CONST;

options.TRAIN_SET_LABEL_CONSTANT = 1;
options.CROSSVALIDATION_SET_LABEL_CONSTANT = 2;
options.TEST_SET_LABEL_CONSTANT = 3;

options.POLY_FADE_MODEL_LABEL_CONSTANT = 1;
options.LOG_FADE_MODEL_LABEL_CONSTANT = 2;

options.ONLY_RSSI_DATA = 'onlyRssi';
options.RSSI_AND_ORIENTATION_DATA = 'rssiAndOrientation';

%% CONFIGURATION

options.WSIZE_S = 3;
options.WINC_S  = 1.5;

options.FADE_MODEL_TO_USE = options.POLY_FADE_MODEL_LABEL_CONSTANT;  % POLY_FADE_MODEL_LABEL_CONSTANT LOG_FADE_MODEL_LABEL_CONSTANT
options.INPUT_DATA_TYPE = options.ONLY_RSSI_DATA;
if strcmp(options.INPUT_DATA_TYPE,options.RSSI_AND_ORIENTATION_DATA)
    warning('in this implementation angles do not add information. The overall performances degrade if this model is used!');
end
options.POLYNOMIAL_FEATURES_DEGREE = 4; %used only if FADE_MODEL_TO_USE = POLY_FADE_MODEL_LABEL_CONSTANT

options.RSSI_AXIS_MIN_VALUE = -110;
options.RSSI_AXIS_MAX_VALUE = 0;

options.VERBOSITY_LEVEL = 10;

options.NUMBER_OF_RANOMLY_CHOSEN_FIGURE_TO_PLOT = 0;

options.FILES_INDEXES_TO_PLOT = [1];%,9,17]; %set this to empty to plot only one (randomly chosen) file.
if size(options.FILES_INDEXES_TO_PLOT,2) > size(options.LOG_FILE_PATH,1)
    warning('size(options.FILES_INDEXES_TO_PLOT,2) > size(options.LOG_FILE_PATH,1)');
    options.FILES_INDEXES_TO_PLOT = [];
end

options.DECIMATION_FACTOR = 1; 
if options.DECIMATION_FACTOR < 1
    error('Decimation factor shall be >= 1');
end

options.REGULARIZATION_LAMBDA = 5;