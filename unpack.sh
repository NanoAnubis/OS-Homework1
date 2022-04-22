#!/bin/bash

zip=$1
adir=$2
bdir=$3
result=$4

tmp=$(mktemp -d)

#mkdir $adir
#mkdir $bdir
#touch $result

unzip -q "${zip}" -d "${tmp}"

for d in $(find $tmp -mindepth 1 -maxdepth 1)
do
	fn=$(echo $d | cut -d '/' -f 4 | cut -d '-' -f 1)
	
	echo $fn
done


