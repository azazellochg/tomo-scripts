#!/bin/bash

# this script convert a single star file from Gctf to multiple defocus.txt (per tomogram) that can be used by NovaCTF
if [[ $# -lt 2 || $1 == "-h" || $1 == "--help" ]]
then
    cat <<USE

    USAGE: gctf2novactf.sh <micrographs_ctf.star> <number of tilts per stack>

USE
    exit 0
fi

ctffn=${1}
tilts=$2

[ ! -f ${ctffn} ] && echo "ERROR: File ${ctffn} not found" && exit 1

##### expected columns order in input star file ####
# _rlnImageId #7
# _rlnMicrographName #8
# _rlnDefocusU #11
# _rlnDefocusV #12
# _rlnDefocusAngle #13
# _rlnPhaseShift #9
#_rlnCtfFigureOfMerit #6
#_rlnCtfMaxResolution #5
####################################################

##### expected output format ####
# Columns: #1 - micrograph number; #2 - defocus 1 [Angstroms]; #3 - defocus 2; #4 - azimuth of astigmatism; #5 - additional phase shift [radians]; #6 - cross correlation; #7 - spacing (in Angstroms) up to which CTF rings were fit successfully
#1.000000 31500.015625 31000.015625 45.000008 0.000000 -0.008399 15.881481
#################################

rm -f defocus*
echo "Parsing defocus params..."
awk 'NF>3{print $7,$11,$12,$13,$9,$6,$5}' $1 > defocus
split -d -l $tilts defocus defocus

k=1
for i in `ls defocus?? | sort -n`
do
        m=`printf "%02g" $k`
        mv $i TS_${m}_defocus.txt
        ((k++))
done

echo "Output files are TS_XX_defocus.txt"
rm -f defocus
