#!/bin/bash
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}
mdadm --create --verbose /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}
mkdir /mnt/d01
mkfs.xfs -f /dev/md0
mount /dev/md0 /mnt/d01
#echo RAID successfully created!!!
if [ $? -eq 0 ]
then
    echo "RAID successfully created!"
    exit 0
else
    echo "NOT CREATED. FAIL!!!"
    exit 1
fi