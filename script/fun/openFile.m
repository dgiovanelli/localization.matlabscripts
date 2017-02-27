function fileID = openFile( options )

if isfield(options,'FILE_PATH')%if the filename path is provided load it
    fileNamePath = options.FILE_PATH;
else %else open the popup to select the file
    [FileName,PathName,~] = uigetfile('.txt','Select log file');
    fileNamePath = strcat(PathName,FileName);
end

fileID = fopen(fileNamePath,'r');