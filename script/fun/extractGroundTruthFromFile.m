function positions = extractGroundTruthFromFile(fileIdx,options)
% delimiter = ',';
% startRow = 2;
% 
% %% Format string for each line of text:
% %   column1: double (%f)
% %	column2: text (%s)
% %   column3: double (%f)
% %	column4: double (%f)
% % For more information, see the TEXTSCAN documentation.
% formatSpec = '%f%s%f%f%f%[^\n\r]';
% 
% %% Read columns of data according to format string.
% % This call is based on the structure of the file used to generate this code. If an error occurs for a different file, try regenerating the code from the Import Tool.
% dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
% 
% %% Close the text file.
% fclose(fileID);
% 
% %% Post processing for unimportable data.
% % No unimportable data rules were applied during the import, so no post processing code is included. To generate code which works for unimportable data, select unimportable cells
% % in a file and regenerate the script.
% 
% %% Allocate imported array to column variable names
% t = dataArray{:, 1};
% IDs = zeros(size(t));
% for lineNo = 1 : size(t,1)
%     IDs(lineNo) = sscanf(cell2mat(dataArray{:, 2}(lineNo)), '0x%x');
% end
% xpos = dataArray{:, 3};
% ypos = dataArray{:, 4};
% orient = dataArray{:, 5};

load(options.GROUND_TRUTH_FILE_PATH{fileIdx})


positions.id = position.id;
positions.xy = position.xy;
positions.orientation = position.orientation;
positions.timestamp = zeros(size(positions.orientation)); %%all node are fixed for now

