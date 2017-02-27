function distance = rssiToDistanceModel( rssi , options)

distance = 10*10.^((rssi-options.TX_PWR_10M)/(options.K_TF(1)));

end