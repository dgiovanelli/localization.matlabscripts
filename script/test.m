clear;
importOptions; %NB: some option may be discarded

%load data\file
load data\halfOfMUSE_21_02_2016_File
%% load model
%load models\POLY_w_angles.mat
load models\POLY_only_Rssi.mat
%load models\POLYmodel
%load models\ANN2wAnglesAndOrientationmodel
%load models\model
noOfFile = size(file,1);
for fileIdx = 1 : noOfFile
    file{fileIdx}.features = divideSets(file{fileIdx},options);
end

options.FADE_MODEL_TO_USE = model.fadeModelType;
options.INPUT_DATA_TYPE = model.inputDataType;
options.INPUT_DATA_TYPE = model.inputDataType;
options.POLYNOMIAL_FEATURES_DEGREE = model.p;
        
testerr = calculateError(file,model,options,'Test');
disp(testerr);

%save models\model model
