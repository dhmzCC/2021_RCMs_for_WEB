
for S in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
for R in 1 2 3                                             ; do
for V in 1 2                                               ; do

    zip data_STATION_${S}_RCP${R}_VAR${V}_ORIG.zip ./PODACI_txt/STATION_${S}_MOD_*_RCP${R}_VAR${V}_ORIG.txt

done
done
done
