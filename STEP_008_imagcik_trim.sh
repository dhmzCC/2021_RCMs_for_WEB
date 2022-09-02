rm -vf *pr_P0_RAW.png

datoteke=$(ls *.png)

for D in ${datoteke}; do
    cp ${D} radna.png
    rm -vf ${D}
    convert radna.png -trim -bordercolor white -border 15 +repage ${D} 
    rm -vf radna.png
done

mkdir -p PODACI_png_20220902
mv     *png ./PODACI_png_20220902
#rm -vf *.png
