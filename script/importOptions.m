%where take the file
options.FILE_PATH = 'F:\GDrive\CLIMB\WIRELESS\LOG\LOCALIZATION\MUSE_21_02_2016\LOGS\log_52_15.26.30.txt';

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
%IDS_TO_CONSIDER = [32, 33, 34 ,35];

%rssi to m fade model parameters
options.K_TF = [-21.4014];
options.TX_PWR_10M = -67.3450;

options.WSIZE_S = 2;
options.WINC_S  = 0.5;

options.NUMBER_OF_RANOMLY_CHOSEN_FIGURE_TO_PLOT = 4;