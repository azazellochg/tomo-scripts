#!/bin/bash

# compute avg def and stdev for each tilt serie

if [[ $# -lt 1 || $1 == "-h" || $1 == "--help" ]]
then
    cat <<USE
  This script computes average and stdev for defocus values for each tomogram. It uses micrographs_*ctf.star file.
    USAGE: `basename $0` <micrographs_ctf.star file>
    EXAMPLE: `basename $0` micrographs_ctf_000137.star

USE
    exit 0
fi

starfn=$1

[ ! -f $starfn ] && echo "ERROR: file ${starfn} does not exist!" && exit 1

for name in `grep -o "TS_[0-9][0-9]" ${starfn} | sort | uniq | cut -d'_' -f2`
do
grep "TS_${name}" ${starfn} | awk -v name=$name '{ sum += $11; sq += $11^2 } END { if (NR > 0) print "TS_"name, "avgDef="sum / NR, "stdDef="sqrt(sq/NR-(sum/NR)^2) }'
done
