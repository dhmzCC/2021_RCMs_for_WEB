cp -v ORIG/P0*nc ISSUE_TIME
cp -v ORIG/P1*nc ISSUE_TIME


cd ORIG
FILES=$(ls P2*nc)
cd -

for F in ${FILES}; do
    echo ${F}
    cp ./ORIG/${F} test.nc
    cdo settaxis,2041-01-01,12:00:00,3months test.nc test_fix.nc
    mv test_fix.nc ${F}
    mv ${F} ISSUE_TIME
done
