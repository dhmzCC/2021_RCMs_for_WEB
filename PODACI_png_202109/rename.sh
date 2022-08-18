LOC[ 1]=Zagreb
LOC[ 2]=Krapina
LOC[ 3]=Sisak
LOC[ 4]=Karlovac
LOC[ 5]=Varazdin
LOC[ 6]=Koprivnica
LOC[ 7]=Bjelovar
LOC[ 8]=Rijeka
LOC[ 9]=Gospic
LOC[10]=Virovitica
LOC[11]=Pozega
LOC[12]=SlavonskiBrod
LOC[13]=Zadar
LOC[14]=Osijek
LOC[15]=Sibenik
LOC[16]=Vukovar
LOC[17]=Split
LOC[18]=Pazin
LOC[19]=Dubrovnik
LOC[20]=Cakovec
LOC[21]=Djurdjenovac
LOC[22]=Nasice

for SSS in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22; do

    echo $SSS
    mv STATION_${SSS}_MeanChange.png dT_vs_dR_${LOC[$SSS]}.png

done
