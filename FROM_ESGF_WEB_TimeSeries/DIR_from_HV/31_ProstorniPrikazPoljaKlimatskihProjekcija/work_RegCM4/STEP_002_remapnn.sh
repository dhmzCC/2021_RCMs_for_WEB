


FILES=$(ls *.nc)
for G in ${FILES}; do
    echo ${G}
    cdo remapnn,mygrid ${G} remapped_${G}
done
