#!/bin/bash
#Mount the disk partition and create the dir if it doesn't exist

echo start > /tmp/prerun1.log
set -x
bakdrv=$1
images=/mnt/easyPcRecovery/clonezilla/images
txt=$images/images_are_stored_here.txt

mount /dev/$bakdrv /mnt

#If not exists
if [[ ! -d $images ]]; then
    mkdir -p $images
   echo "if /easyPcRecovery/easyPcRecovery.txt exists on root dir" >  $txt
fi

mount --bind $images /home/partimag/

set +x
echo finish >> /tmp/prerun1.log
