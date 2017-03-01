function fileID = openFile( options )

if isfield(options,'LOG_FILE_PATH')%if the filename path is provided load it
    noOfFile = size(options.LOG_FILE_PATH,1);
    fileNamePath = options.LOG_FILE_PATH;
    fileID = zeros(noOfFile,1);
    for fileIdx = 1 : noOfFile
        fileID(fileIdx,1) = fopen(fileNamePath{fileIdx},'r');
    end
else %else open the popup to select the file
    [FileName,PathName,~] = uigetfile('.txt','Select log file','MultiSelect','on');
    noOfFile = size(FileName,2);
    fileNamePath = cell(noOfFile,1);
    fileID = zeros(noOfFile,1);
    for fileIdx = 1:noOfFile
        fileNamePath{fileIdx} = strcat(PathName,FileName{fileIdx});
        fileID(fileIdx,1) = fopen(fileNamePath{fileIdx},'r');
    end
end
