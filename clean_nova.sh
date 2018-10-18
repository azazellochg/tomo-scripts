#!/bin/bash

# this script cleans up TS_XX folders after NovaCTF execution, to save disc space

if [[ $# -lt 1 || $1 == "-h" || $1 == "--help" ]]
then
    cat <<USE

    USAGE: clean_nova.sh <tomo_id>
    EXAMPLE: clean_nova.sh 01
        The script will delete all novaCTF intermediate files in directory TS_01

USE
    exit 0
fi

tomo_dir="TS_$1"
suffix="_dose-filt"

[ ! -d ${tomo_dir} ] && echo "Error: TS_$1 dir not found!" && exit 1
[ ! -f ${tomo_dir}/${tomo_dir}${suffix}.bin1.rec ] && echo "Error: output CTF-corrected tomos not found! Did you run NovaCTF?" && exit 1

rm ${tomo_dir}/${tomo_dir}${suffix}_ctfcorr.st_*
rm ${tomo_dir}/${tomo_dir}${suffix}_ctfcorr.ali_*
rm ${tomo_dir}/${tomo_dir}${suffix}_erased.ali_*
rm ${tomo_dir}/${tomo_dir}${suffix}_filtered.ali_*
rm ${tomo_dir}/${tomo_dir}${suffix}_flipped.ali_*
rm ${tomo_dir}/${tomo_dir}${suffix}_defocus.txt_*
rm ${tomo_dir}/eraser.com_*
rm ${tomo_dir}/eraser.log*
rm ${tomo_dir}/newst.com_*
rm ${tomo_dir}/newst.log*
rm ${tomo_dir}/nova_ctfcorr.com_*
rm ${tomo_dir}/nova_filter.com_*
rm ${tomo_dir}/nova_defocus.com
rm ${tomo_dir}/nova_reconstruct.com
