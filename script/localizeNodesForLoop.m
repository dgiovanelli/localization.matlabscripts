clear;
close all;
%% load data
%load data\RadialExtImported.mat
load data\halfOfMUSE_21_02_2016_File
%load data\log_313_imported
%load data\MUSE_16_05_2016_File.mat
%load data\29Logs.mat

%% load model
%load models\ANN2model
%load models\POLYmodel
%load models\ANN2wAnglesAndOrientationmodel
%load models\ANN2wAnglesmodel2
%load models\POLYwAnglesmodel
%load models\POLYwAnglesmodel3

maxIter = 150;
iterations = 1;
stop = 0;

importOptions; %NB: some option may be discarded

%error('Anche con un learning rate molto basso l errore non è mono tono decrescente...ci potrebbe essere un bug nel codice, controllare ordine di linksAnglesFeature');

while iterations < maxIter + 1 && ~stop
    
    if iterations == 1
        load models\POLY_only_Rssi.mat
        %load models\ANN2_only_Rssi.mat
    else
        load models\POLY_w_angles.mat
        %load models\ANN2_w_angles.mat
    end

    
    options.FADE_MODEL_TO_USE = model.fadeModelType;
    options.INPUT_DATA_TYPE = model.inputDataType;
    options.POLYNOMIAL_FEATURES_DEGREE = model.p;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% calculate layout! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    noOfFile = size(file,1);
    for fileIdx = 1 : noOfFile
        f{1} = file{fileIdx};
        t = estimateLayout(f,model,options,iterations - 1);
        file{fileIdx} = t{1};
        fprintf('Layout done for file %d of %d\n',fileIdx,noOfFile);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% calculate leave-one-out error! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     noOfFile = size(file,1);
%     fileIndexes = 1:noOfFile;
%     noOfLeaveOneOut = noOfFile;
%     options.SETS_PARTITION_POLICY = 3;
%     totErr = cell(noOfLeaveOneOut,1);
%     for leaveOneOutI = 1 : noOfLeaveOneOut
%         
%         options.TEST_SET_FILE_IDX = leaveOneOutI;
%         options.CROSSVALIDATION_SET_FILE_IDX = options.TEST_SET_FILE_IDX;
%         options.TRAIN_SET_FILE_IDX = fileIndexes(~(ismember(fileIndexes,options.TEST_SET_FILE_IDX)));
%         
%         %reassign sets based on the actual configuration
%         noOfFile = size(file,1);
%         for fileIdx = 1 : noOfFile
%             file{fileIdx}.features = divideSets(file{fileIdx},options);
%         end
%         
%         totErr{leaveOneOutI} = calculateErrorOnLayout(file,options,'All',iterations);
%     end
%     

    totErr{1} = calculateErrorOnLayout(file,options,iterations);
    
    rmse = 0;
    rnmse = 0;
    nmae = 0;
    for errNo = 1:size(totErr,1)
        rmse = rmse + totErr{errNo}.rmse/size(totErr,1);
        rnmse = rnmse + totErr{errNo}.rnmse/size(totErr,1);
        nmae = nmae + totErr{errNo}.nmae/size(totErr,1);
    end
    fprintf('Average rmse after localization: %.3f\n',rmse);
    fprintf('Average rnmse after localization: %.3f\n',rnmse);
    fprintf('Average rnmae after localization: %.3f\n',nmae);
    figure(1231)
    subplot(1,3,1)
    plot(iterations,rmse,'o','lineWidth',3)
    grid on;
    hold on;
    xlabel('Iteration')
    ylabel('rmse')
    subplot(1,3,2)
    plot(iterations,rnmse,'o','lineWidth',3)
    grid on;
    hold on;
    xlabel('Iteration')
    ylabel('rnmse')
    drawnow
    
    %layout energy
    En = 0;
    for fileIdx = 1:noOfFile
        noOfSamples = size(file{fileIdx}.layout{iterations},2);
        for sampleIdx = 1:noOfSamples
            validLinks = ~isnan(file{fileIdx}.layout{iterations}{sampleIdx}.energyMatrix) & abs (file{fileIdx}.layout{iterations}{sampleIdx}.energyMatrix) ~= Inf & file{fileIdx}.layout{iterations}{sampleIdx}.energyMatrix ~= 0;
            if sum(sum(validLinks)) ~= 0
                En = En + sum(abs(file{fileIdx}.layout{iterations}{sampleIdx}.energyMatrix(   validLinks   )))/sum(sum(validLinks));
            end
        end
    end
    
    subplot(1,3,3)
    plot(iterations,En,'o','lineWidth',3)
    grid on;
    hold on;
    xlabel('Iteration')
    ylabel('Energy')
    drawnow
    iterations = iterations + 1;
end
iterations = iterations - 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save data\layout_done file options

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% detect and remove bad links! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% noOfFile = size(file,1);
% for fileIdx = 1 : noOfFile
%     files{1} = file{fileIdx};
%     file{fileIdx}.features = detectAndRemoveBadLinks(files,options,iterations);
%     fprintf('Link clean done on file %d/%d\n',fileIdx,noOfFile);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% re-calculate layout! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% importOptions; %NB: some option may be discarded
% options.FADE_MODEL_TO_USE = model.fadeModelType;
% options.INPUT_DATA_TYPE = model.inputDataType;
% options.POLYNOMIAL_FEATURES_DEGREE = model.p;
% 
% noOfFile = size(file,1);
% for fileIdx = 1 : noOfFile
%     files{1} = file{fileIdx};
%     file{fileIdx}.layout{iterations + 1} = estimateLayout(files,model,options);
%     fprintf('Layout done for file %d of %d\n',fileIdx,noOfFile);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% calculate leave-one-out error! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%     totErr{leaveOneOutI} = calculateErrorOnLayout(file,options,'Test',iterations);
% end
totErr{1} = calculateErrorOnLayout(file,options,iterations);
 
rmse = 0;
rnmse = 0;
nmae = 0;
for errNo = 1:size(totErr,1)
    rmse = rmse + totErr{errNo}.rmse/size(totErr,1);
    rnmse = rnmse + totErr{errNo}.rnmse/size(totErr,1);
    nmae = nmae + totErr{errNo}.nmae/size(totErr,1);
end
fprintf('Average mse after localization and link clean: %.3f, before localization it was: %.3f\n',rmse,model.modelError.test.rmse);
fprintf('Average nmse after localization and link clean: %.3f, before localization it was: %.3f\n',rnmse,model.modelError.test.rnmse);
fprintf('Average nmae after localization and link clean: %.3f, before localization it was: %.3f\n',nmae,model.modelError.test.nmae);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save data\layout_done file options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot layout! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options.OUTPUT_GIF_FILEPATH = '..\output\nodeMap_preclean.gif';
plotNodesLayout(file, options, 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% re-Plot layout! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options.OUTPUT_GIF_FILEPATH = '..\output\nodeMap_iter.gif';
plotNodesLayout(file, options, iterations);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


