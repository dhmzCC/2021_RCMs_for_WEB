datoteke=$(ls *.png)

for D in ${datoteke}; do
    convert ${D} -trim +repage trim_${D} 
done
