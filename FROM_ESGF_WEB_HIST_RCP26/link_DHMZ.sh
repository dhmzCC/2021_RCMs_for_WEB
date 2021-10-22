

INPUT=/home/ivan/DIR_WORK/DIR_WEB/FROM_ESGF_WEB_TimeSeries/DHMZ_RCM_station_data_1971-2070
 CORE=EUR-11_HA_rcp26_DHMZ-RegCM42_v1_mon_HISTincluded_1971-2070.nc

STAT[ 1]=Zagreb
STAT[ 2]=Krapina
STAT[ 3]=Sisak
STAT[ 4]=Karlovac
STAT[ 5]=Varazdin

STAT[ 6]=Koprivnica
STAT[ 7]=Bjelovar
STAT[ 8]=Rijeka
STAT[ 9]=Gospic
STAT[10]=Virovitica

STAT[11]=Pozega
STAT[12]=SlBrod
STAT[13]=Zadar
STAT[14]=Osijek
STAT[15]=Sibenik

STAT[16]=Vukovar
STAT[17]=Split
STAT[18]=Pazin
STAT[19]=Dubrovnik
STAT[20]=Cakovec

STAT[21]=Djurdjenovac
STAT[22]=Nasice


for MOD  in HA     ; do
for SCEN in 26     ; do
for STT  in {1..22}; do
for VAR  in pr tas ; do
    
    ln -sf ${INPUT}/${STAT[${STT}]}_${VAR}_EUROPE_${MOD}_${SCEN}_1971-2070.nc STATION_${STT}_${VAR}_EUR-11_${MOD}_rcp${SCEN}_DHMZ-RegCM42_v1_mon_HISTincluded_1971-2070.nc

done
done
done
done
