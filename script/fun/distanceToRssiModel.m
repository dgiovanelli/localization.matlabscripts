function rssi = distanceToRssiModel( distance, options )

rssi =  options.TX_PWR_10M+options.K_TF(1)*log10(distance/10);

end