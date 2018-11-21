#!/bin/bash
# based on script from Dustin Morado

[ -z $IMOD_DIR ] && echo "Error: IMOD not found!" && exit 1

if [[ $# -lt 2 || $1 == "-h" || $1 == "--help" ]]
then
    cat <<USE
  This script uses IMOD's newstack program to sort tilt series files by tilt angle and produce a sorted stack, rawtlt file and dose file.
    USAGE: `basename $0` [tilt series index] <dose per tilt>
    EXAMPLE: `basename $0` 13 3.5
        Which will process all TS_013_*_aligned.mrc files with dose of 3.5e/A^2 per tilt

    IMPORTANT: Specify dose per tilt, not per frame!
USE
    exit 0
fi

idx=$1
doserate=$2
idx=`printf "%03d" $idx`

[ ! -d TS_${idx} ] && mkdir TS_${idx}
total=`ls TS_${idx}_*_aligned.mrc 2>/dev/null | wc -l`
[ $total -eq 0 ] && echo "No files found matching TS_${idx}_*_aligned.mrc!" && exit 1

# make file list sorted by tilt angle
rm -f .TS_${idx}_filelist
echo $total > .TS_${idx}_filelist

for i in `ls TS_${idx}_*_aligned.mrc | sort -t_ -n -k 4,4`
do
        echo -e "${i}\n0" >> .TS_${idx}_filelist
done

newstack -q -filein .TS_${idx}_filelist -output TS_${idx}/TS_${idx}_aligned.mrc
rm -f .TS_${idx}_filelist

# make rawtlt file
ls TS_${idx}_*_aligned.mrc | sort -t_ -n -k 4,4 | cut -d'_' -f4 > TS_${idx}/TS_${idx}_dose-filt.rawtlt

# make dose file
dose=0.0
rm -f .TS_${idx}_doselist
for i in `ls TS_${idx}_*_aligned.mrc | sort -t_ -n -k 3,3`
do
        echo $i $dose >> .TS_${idx}_doselist
        dose=`echo "scale=2;$dose + $doserate" | bc`
done

sort -t_ -n -k 4,4 .TS_${idx}_doselist | cut -d' ' -f2 > TS_${idx}/TS_${idx}_dose_list.csv
rm -f .TS_${idx}_doselist

echo "DONE! Sorted tilt series files by tilt angle for TS_${idx}"
