#!/bin/bash

# This script greps Z-SHIFT values from tilt.com for 
# each tomo and creates TS_XX/TS_XX_defocus_shift.txt 
# files containing a single value:
# defocus_shift=THICKNESS/2+SHIFT
# This file is optionally used by NovaCTF

ls -d TS_?? 2>&1 > /dev/null || (exit 1 && echo "TS_XX folders not found. Are you in a correct dir?")

for i in `ls -d TS_?? | cut -d_ -f2 | sort -n`
do
        rm -f TS_${i}/TS_${i}_defocus_shift.txt # clean up just in case
        thickness=`grep THICKNESS TS_${i}/tilt.com | cut -d' ' -f2`
        shift=`grep SHIFT TS_${i}/tilt.com | cut -d' ' -f3`
        finalShift=`echo "scale=2; $thickness/2+$shift" | bc`
        echo $finalShift >> TS_${i}/TS_${i}_defocus_shift.txt
        echo "Tomogram ${i}: thickness=$thickness, Zshift=$shift, defocus shift=$finalShift"
done
