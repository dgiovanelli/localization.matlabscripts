function idx = findID(IDrx, availableIDs)

idx = find(availableIDs == IDrx);

numberOfCorrispondence = size(idx,1);

if numberOfCorrispondence == 0
    idx = 0;
elseif numberOfCorrispondence ~= 1
    warning('the IDrx has been found multiple times in availableIDs');
end