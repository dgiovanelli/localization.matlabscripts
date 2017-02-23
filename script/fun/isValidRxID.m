function isValid = isValidRxID(IDrx)

isValid = IDrx ~= 254 && IDrx ~= 255 && IDrx ~= 0 && IDrx > 0;