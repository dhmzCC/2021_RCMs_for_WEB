

cd ISSUE_TIME
FILES=$(ls *.nc)

for F in ${FILES}; do
    echo ${F}
    cdo splitseas ${F} ${F}_
done

FILES=$(ls *_???.nc)
for G in ${FILES}; do
    echo ${G}
    cdo splitvar ${G} ${G}_
done
