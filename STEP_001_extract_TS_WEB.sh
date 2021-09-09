# Log 2021 02 23
#Reads files from ESGF and extracts for three locations.
#DHMZ simulations are extracted by Lidija Srnec

DIRIN=/media/ivan/MyBook/BACKUP_IG_202009/bonus/FROM_ESGF_UKV
DIROT=/home/ivan/DIR_WORK/DIR_WEB/FROM_ESGF_WEB_TimeSeries

#---------------------------------------------------------------------------------

#Izvor koordinate: Google
LON[ 1]=15.9819 ; LAT[ 1]=45.8150   #Zagreb
LON[ 2]=15.8724 ; LAT[ 2]=46.1605   #Krapina
LON[ 3]=16.3731 ; LAT[ 3]=45.4851   #Sisak
LON[ 4]=15.5553 ; LAT[ 4]=45.4929   #Karlovac
LON[ 5]=16.3366 ; LAT[ 5]=46.3057   #Varazdin

LON[ 6]=16.8335 ; LAT[ 6]=46.1639   #Koprivnica
LON[ 7]=16.8423 ; LAT[ 7]=45.8988   #Bjelovar
LON[ 8]=14.4422 ; LAT[ 8]=45.3271   #Rijeka
LON[ 9]=15.3750 ; LAT[ 9]=44.5469   #Gospic
LON[10]=17.3855 ; LAT[10]=45.8316   #Virovitica

LON[11]=17.6745 ; LAT[11]=45.3315   #Pozega
LON[12]=18.0116 ; LAT[12]=45.1631   #Slavonski Brod
LON[13]=15.2314 ; LAT[13]=44.1194   #Zadar
LON[14]=18.6955 ; LAT[14]=45.5550   #Osijek
LON[15]=15.8952 ; LAT[15]=43.7350   #Sibenik

LON[16]=19.0010 ; LAT[16]=45.3452   #Vukovar
LON[17]=16.4402 ; LAT[17]=43.5081   #Split
LON[18]=13.9373 ; LAT[18]=45.2398   #Pazin
LON[19]=18.0944 ; LAT[19]=42.6507   #Dubrovnik
LON[20]=16.4380 ; LAT[20]=46.3897   #Cakovec

LON[21]=18.0529 ; LAT[21]=45.5409   #Djurdjenovac
LON[22]=18.0951 ; LAT[22]=45.4947   #Nasice

#---------------------------------------------------------------------------------


cd ${DIRIN}
#FILES=$(ls *.nc);
FILES=$(ls *historical*ETH*.nc); #fix
cd -

for F in ${FILES}; do

	echo ${F}

	for S in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22; do

		cdo remapbil,lon=${LON[$S]}/lat=${LAT[$S]} ${DIRIN}/${F} ${DIROT}/STATION_${S}_${F}

	done #stations

done #files
