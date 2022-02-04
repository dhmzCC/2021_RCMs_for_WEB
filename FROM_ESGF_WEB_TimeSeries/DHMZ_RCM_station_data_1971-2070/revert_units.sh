
#for STT in Bjelovar Cakovec Djurdjenovac Dubrovnik Gospic Karlovac Koprivnica Krapina Nasice Osijek Pazin Pozega Rijeka Sibenik Sisak SlBrod Split Varazdin Virovitica Vukovar Zadar Zagreb; do
for STT in Varazdin           ; do
for MOD in CN EC HA MP        ; do
for RCP in 26 45 85           ; do

    cdo addc,273.15        ./LIDIJA_ORIG/${STT}_tas_EUROPE_${MOD}_${RCP}_1971-2070.nc ${STT}_tas_EUROPE_${MOD}_${RCP}_1971-2070.nc
    cdo divc,86400 -divdpm ./LIDIJA_ORIG/${STT}_pr_EUROPE_${MOD}_${RCP}_1971-2070.nc ${STT}_pr_EUROPE_${MOD}_${RCP}_1971-2070.nc

done
done
done
