function fileID = openFile( fileNamePath )

if exist('fileNamePath','var') %if the filename path is provided load it
    
else %else open the popup to select the file
    [FileName,PathName,~] = uigetfile('.txt','Select log file');
    fileNamePath = strcat(PathName,FileName);
end

fileID = fopen(fileNamePath,'r');