rm -vf *pr_P0_RAW.png

datoteke=$(ls *.png)

for D in ${datoteke}; do
    cp ${D} radna.png
    rm -vf ${D}
    convert radna.png -trim +repage ${D} 
    rm -vf radna.png
done

mv     *png ./PODACI_png_20220818
#rm -vf *.png
