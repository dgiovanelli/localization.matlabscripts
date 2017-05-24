clear;
importOptions; %NB: some option may be discarded
%% load data
%load data\TwoLogsImportedFile
load data\log_313_imported

%% load model
load models\model
%load models\POLYmodel
%load models\ANN2wAnglesAndOrientationmodel
%load models\model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% calculate layout! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% importOptions; %NB: some option may be discarded
options.FADE_MODEL_TO_USE = model.fadeModelType;
options.INPUT_DATA_TYPE = model.inputDataType;
options.POLYNOMIAL_FEATURES_DEGREE = model.p;

noOfFile = size(file,1);
for fileIdx = 1 : noOfFile
    f{1} = file{fileIdx};
    t = estimateLayout(f,model,options);
    file{fileIdx} = t{1};
    fprintf('Layout done for file %d of %d\n',fileIdx,noOfFile);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% calculate leave-one-out error! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noOfFile = size(file,1);
fileIndexes = 1:noOfFile;
noOfLeaveOneOut = noOfFile;
options.SETS_PARTITION_POLICY = 3;
totErr = cell(noOfLeaveOneOut,1);
for leaveOneOutI = 1 : noOfLeaveOneOut
    
    options.TEST_SET_FILE_IDX = leaveOneOutI;
    options.CROSSVALIDATION_SET_FILE_IDX = options.TEST_SET_FILE_IDX;
    options.TRAIN_SET_FILE_IDX = fileIndexes(~(ismember(fileIndexes,options.TEST_SET_FILE_IDX)));
    
    %reassign sets based on the actual configuration
    noOfFile = size(file,1);
    for fileIdx = 1 : noOfFile
        file{fileIdx}.features = divideSets(file{fileIdx},options);
    end
    
    totErr{leaveOneOutI} = calculateErrorOnLayout(file,options,'Test',1);
end

rmse = 0;
rnmse = 0;
nmae = 0;
for errNo = 1:size(totErr,1)
    rmse = rmse + totErr{errNo}.rmse/size(totErr,1);
    rnmse = rnmse + totErr{errNo}.rnmse/size(totErr,1);
    nmae = nmae + totErr{errNo}.nmae/size(totErr,1);
end
fprintf('Average rmse after localization: %.3f, before localization it was: %.3f\n',rmse,model.modelError.test.rmse);
fprintf('Average rnmse after localization: %.3f, before localization it was: %.3f\n',rnmse,model.modelError.test.rnmse);
fprintf('Average nmae after localization: %.3f, before localization it was: %.3f\n',nmae,model.modelError.test.nmae);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save data\layout_done file options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% detect and remove bad links! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% noOfFile = size(file,1);
% for fileIdx = 1 : noOfFile
%     files{1} = file{fileIdx};
%     file{fileIdx}.features = detectAndRemoveBadLinks(files,options,1);
%     fprintf('Link clean done on file %d/%d\n',fileIdx,noOfFile);
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% re-calculate layout! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% importOptions; %NB: some option may be discarded
% options.FADE_MODEL_TO_USE = model.fadeModelType;
% options.INPUT_DATA_TYPE = model.inputDataType;
% options.POLYNOMIAL_FEATURES_DEGREE = model.p;
% 
% noOfFile = size(file,1);
% for fileIdx = 1 : noOfFile
%     files{1} = file{fileIdx};
%     file{fileIdx}.layout{2} = estimateLayout(files,model,options);
%     fprintf('Layout done for file %d of %d\n',fileIdx,noOfFile);
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% calculate leave-one-out error! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% noOfFile = size(file,1);
% fileIndexes = 1:noOfFile;
% noOfLeaveOneOut = noOfFile;
% options.SETS_PARTITION_POLICY = 3;
% totErr = cell(noOfLeaveOneOut,1);
% for leaveOneOutI = 1 : noOfLeaveOneOut
%     
%     options.TEST_SET_FILE_IDX = leaveOneOutI;
%     options.CROSSVALIDATION_SET_FILE_IDX = options.TEST_SET_FILE_IDX;
%     options.TRAIN_SET_FILE_IDX = fileIndexes(~(ismember(fileIndexes,options.TEST_SET_FILE_IDX)));
%     
%     %reassign sets based on the actual configuration
%     noOfFile = size(file,1);
%     for fileIdx = 1 : noOfFile
%         file{fileIdx}.features = divideSets(file{fileIdx},options);
%     end
%     
%     totErr{leaveOneOutI} = calculateErrorOnLayout(file,options,'Test',2);
% end
% 
% rmse = 0;
% rnmse = 0;
% nmae = 0;
% for errNo = 1:size(totErr,1)
%     rmse = rmse + totErr{errNo}.mse/size(totErr,1);
%     rnmse = rnmse + totErr{errNo}.nmse/size(totErr,1);
%     nmae = nmae + totErr{errNo}.nmae/size(totErr,1);
% end
% fprintf('Average mse after localization and link clean: %.3f, before localization it was: %.3f\n',rmse,model.modelError.test.mse);
% fprintf('Average nmse after localization and link clean: %.3f, before localization it was: %.3f\n',rnmse,model.modelError.test.nmse);
% fprintf('Average nmae after localization and link clean: %.3f, before localization it was: %.3f\n',nmae,model.modelError.test.nmae);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data\layout_done file options
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot layout! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% options.OUTPUT_GIF_FILEPATH = '..\output\nodeMap_preclean.gif';
% plotNodesLayout(file, options, 1);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% re-Plot layout! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% options.OUTPUT_GIF_FILEPATH = '..\output\nodeMap_postclean.gif';
% plotNodesLayout(file, options, 2);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


