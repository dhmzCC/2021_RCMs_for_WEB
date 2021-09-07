DIRIN=./FROM_ESGF_WEB_TimeSeries
DIROT=./FROM_ESGF_WEB_HIST_RCP45
Nrcp45=17

mapfile -t myArray_HISTY < models_HIST_subset_RCP45.txt
mapfile -t myArray_RCP45 < models_RCP45.txt

  for MOD in {0..17}; do
	echo ${myArray[$MOD]}

        for STT in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22; do
	for VAR in tas pr;  do

		cdo -f nc copy ${DIRIN}/STATION_${STT}_${VAR}_EUR-11_${myArray_HISTY[$MOD]}_mon_*.nc temp_HISTY.nc 
		cdo -f nc copy ${DIRIN}/STATION_${STT}_${VAR}_EUR-11_${myArray_RCP45[$MOD]}_mon_*.nc temp_RCP.nc 
                cdo -f nc copy temp_HISTY.nc temp_RCP.nc ${DIROT}/STATION_${STT}_${VAR}_EUR-11_${myArray_RCP45[$MOD]}_mon_HISTincluded.nc
                cdo -f nc seldate,1971-01-01,2070-12-31 ${DIROT}/STATION_${STT}_${VAR}_EUR-11_${myArray_RCP45[$MOD]}_mon_HISTincluded.nc ${DIROT}/STATION_${STT}_${VAR}_EUR-11_${myArray_RCP45[$MOD]}_mon_HISTincluded_1971-2070.nc
		rm temp_HISTY.nc temp_RCP.nc

	done #variable
	done #station

done #model
