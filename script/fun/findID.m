function idx = findID(IDrx, availableIDs)

idx = find(availableIDs == IDrx);

numberOfCorrispondences = size(idx,1);

if numberOfCorrispondences == 0
    idx = 0;
elseif numberOfCorrispondences ~= 1
    warning('the IDrx has been found multiple times in availableIDs');
end