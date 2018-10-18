#!/bin/bash

#This script creates Dynamo volume list file (.vll) for the import into the catalogue.
#It mainly greps refined tilt angles from TS*.tlt file. Should be run inside etomo/inputs folder

if [[ $# -lt 1 || $1 == "-h" || $1 == "--help" ]]
then
    cat <<USE

    USAGE: create_vll.sh <unbinned pixel size (A)>

USE
    exit 0
fi

######### OPTIONS #######
apix=${1}
ftype=1
bin=4
dir="inputs_bin4"
#########################

ls -d TS_?? 2>&1 > /dev/null || (exit 1 && echo "TS_XX folders not found. Are you in a correct dir?")
rm -f tomo_list.vll
apix=`echo "scale=2; $apix*$bin" | bc`

for i in `ls -d TS_?? | cut -d_ -f2 | sort -n`
do
        tiltfn="TS_${i}/TS_${i}_dose-filt.tlt"
        [ ! -f ${tiltfn} ] && echo "Tilt angles file not found: $tiltfn" && exit 1
        mintilt=`awk 'NR==1{printf "%0.2f",$0}' ${tiltfn}`
        maxtilt=`awk 'END{printf "%0.2f",$0}' ${tiltfn}`
        echo "${dir}/TS_${i}.rec 
* apix=${apix}
* ftype=${ftype}
* ytilt=${mintilt},${maxtilt}" >> tomo_list.vll
done
echo "Created volume list file: tomo_list.vll"
