

cd ISSUE_TIME
FILES=$(ls *.nc)
cd -


for G in ${FILES}; do
    echo ${G}
    cdo remapnn,mygrid ./ISSUE_TIME/${G} ./ISSUE_GRID/remapped_${G}
done
