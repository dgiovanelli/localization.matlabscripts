function time_matlab = unixToMatlabTime( time_unix )
time_reference = datenum('1-Gen-1970 01:00:00'); %The hour is 01:00:00 to calculate the hour in Italy, to use UTC set hour to 00:00:00, or decomment the next line
%time_reference = datenum('1970', 'yyyy'); 
time_matlab = time_reference + time_unix / 8.64e7;
