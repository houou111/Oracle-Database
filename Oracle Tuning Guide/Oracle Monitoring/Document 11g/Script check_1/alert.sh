#!/bin/bash
# Tested Under FreeBSD and OS X
#FS="/u02"
THRESHOLD=95
df -h | grep -v "^Filesystem" | awk '{print $6}' | sed "s:%::" | while read output1
do
OUTPUT=($(LC_ALL=C df -h $output1))
CURRENT=$(echo ${OUTPUT[11]} | sed 's/%//')
MOUNTPOINT=$(echo ${OUTPUT[12]} | sed 's/[!@#\/$%^&*()]//')
if [ $CURRENT -gt $THRESHOLD ] ; then
   /usr/binhtv/cmdsql.sh "Space $output1 on $(hostname) is $CURRENT%"
fi
done
