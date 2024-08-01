#!/bin/bash
path=$1
targetName=$2
files=""
j=1
for i in $* 
do
if [ "$j" -gt 2 ]; then
   files+=" "${i}
   #echo $i;
fi
((j++))
#echo "j=$j"
done
#echo $files;
cd $path
zip -m $targetName".zip" $files
echo "true";