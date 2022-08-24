rm -vf *pr_P0_RAW.png

datoteke=$(ls *.png)

for D in ${datoteke}; do
    convert ${D} -trim +repage trim_${D} 
done

mv trim*png ./PODACI_png_20220818
rm -vf *.png
