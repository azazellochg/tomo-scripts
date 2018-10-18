#!/bin/bash

# this script checks if you have exactly the same number of lines/tilts in defocus files, tilt angle files and tilt stacks. But it cannot check the files order!!!
[ -z $IMOD_DIR ] && echo "Error: IMOD not found!" && exit 1

# check if we are in correct PWD
echo $PWD | grep -q "etomo" > /dev/null 2>&1
[ $? != 0 ] && echo "ERROR: We are not in etomo/inputs folder!!!" && exit 1

for i in `ls -d TS_?? | cut -d'_' -f2`
do

defn=`wc -l TS_${i}/TS_${i}_defocus.txt | awk '{print $1}'`
tltn=`wc -l TS_${i}/TS_${i}_dose-filt.tlt | awk '{print $1}'`
stn=`header -s TS_${i}/TS_${i}_dose-filt.st | awk '{print $3}'`

if [[ $defn -ne $tltn || $defn -ne $stn || $tltn -ne $stn ]]
then
        echo "Numbers do not match for TS_${i}: defocus file - $defn lines, tlt file - $tltn lines, stack - $stn frames"
else
        echo "TS_${i} OK!"
fi

done
