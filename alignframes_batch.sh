#!/bin/bash
# based on scripts from Dustin Morado & Oleksiy Kovtun

SECONDS=0
[ -z $IMOD_DIR ] && echo "Error: IMOD not found!" && exit 1

if [[ $# -lt 2 || $1 == "-h" || $1 == "--help" ]]
then
    cat <<USE
  This script uses IMOD's alignframes program to align multiple tilt series, consisting of tif frame stacks.
  It will process all TS_*.tif files in current directory.
    USAGE: `basename $0` <gain ref file> <defects file>
    EXAMPLE: `basename $0` gainref.dm4 defects.txt

USE
    exit 0
fi

total=`ls TS_*.tif 2>/dev/null | wc -l`
[ $total -eq 0 ] && echo "No *.tif files were found in current directory!" && exit 1
count=1

[[ -f $1 && -f $2 ]] || (echo "Error: check that $1 and $2 files exist!" && exit 1)

for i in `ls -v TS_*.tif`
do
        logFn=`echo ${i} | cut -d'_' -f1,2`
        [ -f ${i/%\.tif/_aligned.mrc} ] && let "count++" && continue
        echo -en "Aligning tif stack $count/$total... \r"
        alignframes -InputFile ${i} \
                    -OutputImageFile ${i/%\.tif/_aligned.mrc} \
                    -GainReferenceFile $1 \
                    -RotationAndFlip -1 \
                    -CameraDefectFile $2 \
                    -UseGPU 0 \
                    -PairwiseFrames -1 \
                    -Group 2 \
                    -ShiftLimit 20 \
                    -RefineAlignment 5 \
                    -StopIterationsAtShift 0.1 \
                    -FRCOutputFile ${i/%\.tif/_aligned.frc} \
                    -PlottableShiftFile ${i/%\.tif/_shifts.txt} \
                    -UseHybridShifts >> ${logFn}_aligned.log 2>&1
((count++))
done
let count--
echo "Aligning tilt stack $count/$total...done!"

echo -en "Getting freq. values at FRC=0.5 from *align.log...\r"
for i in `ls -v TS_*.tif | cut -d'_' -f1,2 | sort -u`
do
        grep 'FRC crossings 0.5: [0-9]\.[0-9][0-9][0-9][0-9]' ${i}_aligned.log | awk '{print $4}' > tmp1
        egrep -o '(TS_).+(.tif)' ${i}_aligned.log > tmp2
        echo -e "\n--- FRC crossings at 0.5 ---\n" >> ${i}_aligned.log
        paste tmp2 tmp1 >> ${i}_aligned.log
        rm -f tmp1 tmp2
done
echo "Getting freq. values at FRC=0.5 from *align.log...done!"

[ ! -d logs ] && mkdir logs
mv *aligned.frc *_shifts.txt *_aligned.log logs/

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo -e "Check output files:\n\t*_aligned.mrc\n\tlogs/*_shifts.txt\n\tlogs/*_aligned.frc\n\tlogs/*_aligned.log\n"
