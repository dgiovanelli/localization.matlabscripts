function isValid = isValidRxID(IDrx,options)

isValid = IDrx ~= 254 && IDrx ~= 255 && IDrx ~= 0 && IDrx > 0;

if isfield(options,'IDS_TO_CONSIDER')%if the IDS_TO_CONSIDER is provided use it
    if ~isempty(options.IDS_TO_CONSIDER)
        isValid = isValid && ~isempty(find(options.IDS_TO_CONSIDER == IDrx,1)); 
    end
end
