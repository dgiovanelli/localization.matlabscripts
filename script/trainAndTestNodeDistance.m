%NOTES:
% Using NN and options.LEAVE_ONE_OUT_POLICY = 3 (file based) leads to rather stable resuls along repetitions, but since every log file
% is representative of a set of distances (bacuase of the radius), the error along LeaveOneOutI is related to distances. The NMSE is much
% more stable and it should be used to calculate the best configuration.
% When using options.LEAVE_ONE_OUT_POLICY = 1, by setting options.MERGE_TEST_AND_CORSSVALIDATION = true it activate early stopping of NN training
% making it faster.
% for the ANN2 model, the only meaningful options.LEAVE_ONE_OUT_POLICY is 3, (since with a single link it cannot work (it needs at least 3 nodes),
% instead with a single triangle as test the links don't have multiple preditions to average on)
% This script takes windowed RSSI [dBm] as input nodes distances [meters] as output, all intermediate processes are started and ended
% within the script, then, for instance, the ANN2 algorithm that uses triangles has to aggregate all estimation and return only one estimation
% for each link length.

if 1
    clc
    clear;
    importOptions
    load data\29Logs.mat
    %load data\MUSE_21_02_2016_File.mat
    confCount = 1;
    %%ANN2 - RSSI with angles
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% configurations start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     configurations{confCount}.LEAVE_ONE_OUT_POLICY = 0;%0: don't use leave one out, use SETS_PARTITION_POLICY, use default sets 1: triangles based, 2: links based, 3: files based
%     configurations{confCount}.FADE_MODEL_TO_USE = options.ANN2_MODEL_LABEL_CONSTANT;
%     configurations{confCount}.INPUT_DATA_TYPE = options.RSSI_AND_ANGLES_DATA;   %ONLY_RSSI_DATA;%RSSI_AND_ANGLES_DATA;
%     configurations{confCount}.ANN_HIDDEN_LAYERS = [9, 9];
%     configurations{confCount}.USE_NORMALIZED_ERROR = true;
%     confCount = confCount + 1;
%     
%     configurations{confCount}.LEAVE_ONE_OUT_POLICY = 0;%0: don't use leave one out, use SETS_PARTITION_POLICY, use default sets 1: triangles based, 2: links based, 3: files based
%     configurations{confCount}.FADE_MODEL_TO_USE = options.ANN2_MODEL_LABEL_CONSTANT;
%     configurations{confCount}.INPUT_DATA_TYPE = options.RSSI_AND_ANGLES_DATA;   %ONLY_RSSI_DATA;%RSSI_AND_ANGLES_DATA;
%     configurations{confCount}.ANN_HIDDEN_LAYERS = [9, 9, 9];
%     configurations{confCount}.USE_NORMALIZED_ERROR = true;
%     confCount = confCount + 1;
%     
%     configurations{confCount}.LEAVE_ONE_OUT_POLICY = 0;%0: don't use leave one out, use SETS_PARTITION_POLICY, use default sets 1: triangles based, 2: links based, 3: files based
%     configurations{confCount}.FADE_MODEL_TO_USE = options.ANN2_MODEL_LABEL_CONSTANT;
%     configurations{confCount}.INPUT_DATA_TYPE = options.RSSI_AND_ANGLES_DATA;   %ONLY_RSSI_DATA;%RSSI_AND_ANGLES_DATA;
%     configurations{confCount}.ANN_HIDDEN_LAYERS = [12, 12, 12];
%     configurations{confCount}.USE_NORMALIZED_ERROR = true;
%     confCount = confCount + 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% configurations end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%ANN2 - only RSSI
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% configurations start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    configurations{confCount}.LEAVE_ONE_OUT_POLICY = 0;%0: don't use leave one out, use SETS_PARTITION_POLICY, use default sets 1: triangles based, 2: links based, 3: files based
    configurations{confCount}.FADE_MODEL_TO_USE = options.ANN2_MODEL_LABEL_CONSTANT;
    configurations{confCount}.INPUT_DATA_TYPE = options.ONLY_RSSI_DATA;   %ONLY_RSSI_DATA;%RSSI_AND_ANGLES_DATA;
    configurations{confCount}.ANN_HIDDEN_LAYERS = [9, 9];
    configurations{confCount}.USE_NORMALIZED_ERROR = true;
    confCount = confCount + 1;
    
    configurations{confCount}.LEAVE_ONE_OUT_POLICY = 0;%0: don't use leave one out, use SETS_PARTITION_POLICY, use default sets 1: triangles based, 2: links based, 3: files based
    configurations{confCount}.FADE_MODEL_TO_USE = options.ANN2_MODEL_LABEL_CONSTANT;
    configurations{confCount}.INPUT_DATA_TYPE = options.ONLY_RSSI_DATA;   %ONLY_RSSI_DATA;%RSSI_AND_ANGLES_DATA;
    configurations{confCount}.ANN_HIDDEN_LAYERS = [9, 9, 9];
    configurations{confCount}.USE_NORMALIZED_ERROR = true;
    confCount = confCount + 1;
    
    configurations{confCount}.LEAVE_ONE_OUT_POLICY = 0;%0: don't use leave one out, use SETS_PARTITION_POLICY, use default sets 1: triangles based, 2: links based, 3: files based
    configurations{confCount}.FADE_MODEL_TO_USE = options.ANN2_MODEL_LABEL_CONSTANT;
    configurations{confCount}.INPUT_DATA_TYPE = options.ONLY_RSSI_DATA;   %ONLY_RSSI_DATA;%RSSI_AND_ANGLES_DATA;
    configurations{confCount}.ANN_HIDDEN_LAYERS = [12, 12, 12];
    configurations{confCount}.USE_NORMALIZED_ERROR = true;
    confCount = confCount + 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% configurations end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    noOfConfigurations = size(configurations,2);
    noOfANNToTrain = 20; %TODO: add to options?
    
    for configurationNo = 1:noOfConfigurations
        
        %overwrite default configuration       
        for fn = fieldnames(configurations{configurationNo})'
            options.(fn{1}) = configurations{configurationNo}.(fn{1});
        end
        
        % setup variables for leave one out
        if options.LEAVE_ONE_OUT_POLICY == 0
            noOfLeaveOneOut = 1;
        elseif options.LEAVE_ONE_OUT_POLICY == 1 %%leave one out with triangles
            availableIds = unique([cell2mat(file{1}.features.ID1) ; cell2mat(file{1}.features.ID2)]);%Note: use the same ids for all files
            triangles = nchoosek(availableIds,3);
            noOfTriangles = size(triangles,1);
            noOfLeaveOneOut = noOfTriangles;
            options.SETS_PARTITION_POLICY = 2;
        elseif options.LEAVE_ONE_OUT_POLICY == 2 %%leave one out with single links (similar to triangles, but use just one link)
            availableIds = unique([cell2mat(file{1}.features.ID1) ; cell2mat(file{1}.features.ID2)]);%Note: use the same ids for all files
            links = nchoosek(availableIds,2);
            noOfLinks = size(links,1);
            noOfLeaveOneOut = noOfLinks;
            options.SETS_PARTITION_POLICY = 2;
        elseif options.LEAVE_ONE_OUT_POLICY == 3 %%leave one out with files
            noOfFiles = size(file,1);
            fileIndexes = 1:noOfFiles;
            noOfLeaveOneOut = noOfFiles;
            options.SETS_PARTITION_POLICY = 3;
        else
            error('options.LEAVE_ONE_OUT_POLICY invalid value');
        end
        
        configurations{configurationNo}.model = cell(noOfLeaveOneOut,noOfANNToTrain);
        configurations{configurationNo}.rmse = zeros(noOfLeaveOneOut,noOfANNToTrain);
        configurations{configurationNo}.rnmse = zeros(noOfLeaveOneOut,noOfANNToTrain);
        configurations{configurationNo}.nmae = zeros(noOfLeaveOneOut,noOfANNToTrain);

        for leaveOneOutI = 1 : noOfLeaveOneOut
            
            if options.LEAVE_ONE_OUT_POLICY == 0 %%do not use leave one out
                %use default configuration (stored in importOptions.m file)
            end
            
            if options.LEAVE_ONE_OUT_POLICY == 1 %%leave one out with triangles
                options.TEST_SET_NODES_ID = triangles(leaveOneOutI,:);
                options.CROSSVALIDATION_SET_NODES_ID = options.TEST_SET_NODES_ID;
                options.TRAIN_SET_NODES_ID = availableIds(~(ismember(availableIds,options.TEST_SET_NODES_ID)))';
            end
            
            if options.LEAVE_ONE_OUT_POLICY == 2 %%leave one out with links
                options.TEST_SET_NODES_ID = links(leaveOneOutI,:);
                options.CROSSVALIDATION_SET_NODES_ID = options.TEST_SET_NODES_ID;
                options.TRAIN_SET_NODES_ID = availableIds(~(ismember(availableIds,options.TEST_SET_NODES_ID)))';
            end
            
            if options.LEAVE_ONE_OUT_POLICY == 3%%leave one out with files
                options.TEST_SET_FILE_IDX = leaveOneOutI;
                options.CROSSVALIDATION_SET_FILE_IDX = options.TEST_SET_FILE_IDX;
                options.TRAIN_SET_FILE_IDX = fileIndexes(~(ismember(fileIndexes,options.TEST_SET_FILE_IDX)));
            end
            
            %reassign sets based on the actual configuration
            noOfFile = size(file,1);
            for fileIdx = 1 : noOfFile
                file{fileIdx}.features = divideSets(file{fileIdx},options);
            end
            
            %train and calculate error
            for repetitionNo = 1:noOfANNToTrain
                configurations{configurationNo}.model{leaveOneOutI,repetitionNo} = trainModel(file,options);
                configurations{configurationNo}.model{leaveOneOutI,repetitionNo}.modelError.train = calculateError(file,configurations{configurationNo}.model{leaveOneOutI,repetitionNo},options,'Train');
                %configurations{configurationNo}.model{leaveOneOutI,repetitionNo}.modelError.validation = calculateError(file,configurations{configurationNo}.model{leaveOneOutI,repetitionNo},options,'CrossValidation');
                configurations{configurationNo}.model{leaveOneOutI,repetitionNo}.modelError.test = calculateError(file,configurations{configurationNo}.model{leaveOneOutI,repetitionNo},options,'Test');
                configurations{configurationNo}.rmse(leaveOneOutI,repetitionNo) = configurations{configurationNo}.model{leaveOneOutI,repetitionNo}.modelError.test.rmse;
                configurations{configurationNo}.rnmse(leaveOneOutI,repetitionNo) = configurations{configurationNo}.model{leaveOneOutI,repetitionNo}.modelError.test.rnmse;
                configurations{configurationNo}.nmae(leaveOneOutI,repetitionNo) = configurations{configurationNo}.model{leaveOneOutI,repetitionNo}.modelError.test.nmae;
                %plotModelWithTrainingData(file,configurations{configurationNo}.model{leaveOneOutI,repetitionNo},options);
                fprintf('repetitions: %d/%d, leaveOneOutI: %d/%d, configurationNo: %d/%d\n',repetitionNo ,noOfANNToTrain ,leaveOneOutI ,noOfLeaveOneOut ,configurationNo ,noOfConfigurations );
                fprintf('last rmse: %.2f, last rnmse: %.2f, last nmae: %.2f\n\n',configurations{configurationNo}.rmse(leaveOneOutI,repetitionNo), configurations{configurationNo}.rnmse(leaveOneOutI,repetitionNo), configurations{configurationNo}.nmae(leaveOneOutI,repetitionNo) );
            end
        end
    end
end
rmse = NaN*ones(noOfANNToTrain,noOfConfigurations);
rnmse = NaN*ones(noOfANNToTrain,noOfConfigurations);
nmae = NaN*ones(noOfANNToTrain,noOfConfigurations);

for configurationNo = 1:noOfConfigurations
    if isfield(configurations{configurationNo},'model')
        %noOfANNToTrain = size(configurations{configurationNo}.model,2);
        %noOfLeaveOneOut = size(configurations{configurationNo}.model,1);
        repetitionNo = 1;
        %for repetitionNo = 1:noOfANNToTrain
            if isfield(configurations{configurationNo},'rmse') %fare la media sai su leave-one-out che su repetition!
                rmse(:,configurationNo) = mean(configurations{configurationNo}.rmse,1);%nanmean( configurations{configurationNo}.rmse(configurations{configurationNo}.rmse(:,repetitionNo) ~= 0,repetitionNo) );
            else
                rmse(:,configurationNo) = NaN;
            end
            
            if isfield(configurations{configurationNo},'rnmse')
                rnmse(:,configurationNo) = mean(configurations{configurationNo}.rnmse,1);%nanmean( configurations{configurationNo}.rnmse(configurations{configurationNo}.rnmse(:,repetitionNo) ~= 0,repetitionNo) );
            else
                rnmse(:,configurationNo) = NaN;
            end
            
            if isfield(configurations{configurationNo},'nmae')
                nmae(:,configurationNo) = mean(configurations{configurationNo}.nmae,1);%nanmean( configurations{configurationNo}.nmae(configurations{configurationNo}.nmae(:,repetitionNo) ~= 0,repetitionNo) );
            else
                nmae(:,configurationNo) = NaN;
            end
        %end
    end
end

%importOptions; %reload default values

[minColumnValue ,minColumnIdx ] = min(rmse,[],1);
[~, minGlobaIdx ] = min(minColumnValue);
minMSEIdx = [minColumnIdx(minGlobaIdx), minGlobaIdx];
minMSEValue = rmse(minMSEIdx(1),minMSEIdx(2));

[minColumnValue ,minColumnIdx ] = min(rnmse,[],1);
[~, minGlobaIdx ] = min(minColumnValue);
minNMSEIdx = [minColumnIdx(minGlobaIdx), minGlobaIdx];
minNMSEValue = rnmse(minNMSEIdx(1),minNMSEIdx(2));

[minColumnValue ,minColumnIdx ] = min(nmae,[],1);
[minGlobalValue, minGlobaIdx ] = min(minColumnValue);
minNMAEIdx = [minColumnIdx(minGlobaIdx), minGlobaIdx];
minNMAEValue = nmae(minNMAEIdx(1),minNMAEIdx(2));

bestConfigurationForMSE = minMSEIdx(2);
bestRepetitionForMSE = minMSEIdx(1);

bestConfigurationForNMSE = minNMSEIdx(2);
bestRepetitionForNMSE = minNMSEIdx(1);

bestConfigurationForNMAE = minNMAEIdx(2);
bestRepetitionForNMAE = minNMAEIdx(1);

%save lastRun -v7.3

%%select the model to use in the successive phases %TODO: how to deal with repetitions and leave one out? for now simply select the one with the lowest error
%pause;
fprintf('Remember to check the selected configuration!\n');
selectedConfiguration = bestConfigurationForNMSE;
[~,bestRepetitionIdx] = min(mean(configurations{selectedConfiguration}.rnmse,1));
[~,bestLeaveOneOutIdx] = min(configurations{selectedConfiguration}.rnmse(:,bestRepetitionIdx));
bestModelIdx = [bestLeaveOneOutIdx;bestRepetitionIdx];

model = configurations{selectedConfiguration}.model{bestModelIdx(1),bestModelIdx(2)};

options.MERGE_TEST_AND_CORSSVALIDATION = true;
options.LEAVE_ONE_OUT_POLICY = 0;%configurations{selectedConfiguration}.options.LEAVE_ONE_OUT_POLICY;
%options.USE_NORMALIZED_ERROR = configurations{selectedConfiguration}.USE_NORMALIZED_ERROR;
%options.REGULARIZATION_LAMBDA = configurations{selectedConfiguration}.REGULARIZATION_LAMBDA;
%options.POLYNOMIAL_FEATURES_DEGREE = configurations{selectedConfiguration}.POLYNOMIAL_FEATURES_DEGREE;

if options.LEAVE_ONE_OUT_POLICY == 0
    noOfLeaveOneOut = 1;
%    options.SETS_PARTITION_POLICY = configurations{selectedConfiguration}.SETS_PARTITION_POLICY;
elseif options.LEAVE_ONE_OUT_POLICY == 1 %%leave one out with triangles
    availableIds = unique([cell2mat(file{1}.features.ID1) ; cell2mat(file{1}.features.ID2)]);%Note: use the same ids for all files
    triangles = nchoosek(availableIds,3);
    noOfTriangles = size(triangles,1);
    noOfLeaveOneOut = noOfTriangles;
    options.SETS_PARTITION_POLICY = 2;
elseif options.LEAVE_ONE_OUT_POLICY == 2 %%leave one out with single links (similar to triangles, but use just one link)
    availableIds = unique([cell2mat(file{1}.features.ID1) ; cell2mat(file{1}.features.ID2)]);%Note: use the same ids for all files
    links = nchoosek(availableIds,2);
    noOfLinks = size(links,1);
    noOfLeaveOneOut = noOfLinks;
    options.SETS_PARTITION_POLICY = 2;
elseif options.LEAVE_ONE_OUT_POLICY == 3 %%leave one out with files
    noOfFiles = size(file,1);
    fileIndexes = 1:noOfFiles;
    noOfLeaveOneOut = noOfFiles;
    options.SETS_PARTITION_POLICY = 3;
else
    error('options.LEAVE_ONE_OUT_POLICY invalid value');
end

totErr = cell(noOfLeaveOneOut,1);
noOfFiles = size(file,1);
fileIndexes = 1:noOfFiles;
for leaveOneOutI = 1 : noOfLeaveOneOut
    %options.TEST_SET_FILE_IDX = leaveOneOutI;
    %options.CROSSVALIDATION_SET_FILE_IDX = options.TEST_SET_FILE_IDX;
    %options.TRAIN_SET_FILE_IDX = fileIndexes(~(ismember(fileIndexes,options.TEST_SET_FILE_IDX)));
    
    %reassign sets based on the actual configuration
    noOfFile = size(file,1);
    for fileIdx = 1 : noOfFile
        file{fileIdx}.features = divideSets(file{fileIdx},options);
    end
    
    totErr{leaveOneOutI} = calculateError(file,model,options,'Test');
end


rmse = 0;
rnmse = 0;
nmae = 0;
for errNo = 1:size(totErr,1)
    rmse = rmse + totErr{errNo}.rmse/size(totErr,1);
    rnmse = rnmse + totErr{errNo}.rnmse/size(totErr,1);
    nmae = nmae + totErr{errNo}.nmae/size(totErr,1);
end

modelError.test.rmse = rmse;
modelError.test.rnmse = rnmse;
modelError.test.nmae = nmae;

save models\model model
save data\file file options


% USE NEXT LINES CAREFULLY, IN PARTICULAR IF LEAVE ONE OUT IS USED model{1,bestRepetitionForNMAE} actually use the model calculated for the first LEAVE ONE OUT
% iteration for calculating the error only on the 'Test' files (defined by options.TEST_SET_FILE_IDX)
% minModelErrorForNMAE = calculateError(file,configurations{bestConfigurationForNMAE}.model{1,bestRepetitionForNMAE},options,'Test');
% plotModelWithTrainingData(file,configurations{bestConfigurationForNMAE}.model{1,bestRepetitionForNMAE},options);

% figure
% plot(rmse - mean(rmse))
% hold on
% plot(rnmse - mean(rnmse))
% plot(nmae - mean(nmae))
%  i = 1;
% while 1
%     configurations{bestConfigurationForNMSE}.model{i,bestRepetitionForNMSE}.modelError.test
%     i = i + 1;
% end