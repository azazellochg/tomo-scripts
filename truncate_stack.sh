#!/bin/bash
# This script removes specified sections from tilt series

[ -z $IMOD_DIR ] && echo "Error: IMOD not found!" && exit 1

if [[ $# != 2 || $1 == "-h" || $1 == "--help" ]]
then
    cat <<USE
  This script uses IMOD's newstack program to remove unwanted sections from tilt series stack (TS_XX_dose-filt.st).
  It also updates associated rawtlt file. IMPORTANT: sections are numbered from 1, not 0!
  The script should be run from the pre-processing folder.
    USAGE: `basename $0` <input stack folder> <list of sections>
    EXAMPLE: `basename $0` TS_18 39,40,41,42,43

USE
    exit 0
fi

# check if we are in correct PWD
echo $PWD | grep -q "pre-processing"
[ $? != 0 ] && echo "ERROR: We are not in pre-processing folder!!!" && exit 1

fname=$1
stack="$PWD/$fname/${fname}_dose-filt.st"
secs=$2
rawtlt="$PWD/$fname/${fname}_dose-filt.rawtlt"

[ ! -f $stack ] && echo "Input stack not found: $stack" && exit 1
[ ! -f $rawtlt ] && echo "Input rawtlt file not found: $rawtlt" && exit 1

cd $PWD/$fname
# move original files
mv ${fname}_dose-filt.st ${fname}_dose-filt_orig.st
mv ${fname}_dose-filt.rawtlt ${fname}_dose-filt_orig.rawtlt

newstack -in ${fname}_dose-filt_orig.st -ou ${fname}_dose-filt.st -fromone -exclude $secs

rm -f .tmpsec
IFS=","
for var in $secs
do
        echo $var >> .tmpsec
done
IFS=" "
awk 'NR==FNR{n[$1];next}!(FNR in n)' .tmpsec ${fname}_dose-filt_orig.rawtlt > ${fname}_dose-filt.rawtlt
rm -f .tmpsec 
echo -e "Removed sections `date`: $secs" >> REMOVED_SECTIONS
cd -
echo "Done!"
