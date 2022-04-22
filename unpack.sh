#!/bin/bash

zip=$1
adir=$2
bdir=$3
result=$4

tmp=$(mktemp -d)

mkdir $adir
mkdir $bdir
#touch $result

unzip -q "${zip}" -d "${tmp}"

for d in $(find $tmp -mindepth 1 -maxdepth 1)
do
	fn="$(echo $d | cut -d '/' -f 4 | cut -d '-' -f 1)"
	line=$fn

	if [ $(find $d -mindepth 1 -maxdepth 1 | wc -l) -gt 1 ]
	then
		echo "2 or more files"
		mkdir $bdir/$fn
		find $d -mindepth 1 -maxdepth 1 | xargs -I {} mv {} $bdir/$fn
		continue
	fi
	
	archive="$(find $d -mindepth 1 -maxdepth 1 | cut -d '/' -f 5)"
	
	#check name and extension

	if [ "$fn.tar.xz" = "$archive" ]
	then
		line="$line 0"
	else
		line="$line 1"
	fi

	archive="$d/$archive"

	if [ $(file -b $archive | egrep 'XZ' | wc -l) -eq 1 ] 
	then	
		tar xf $archive -C $adir/
		line="$line 0"
	elif [ $(file -b $archive | egrep "('tar'|'gzip'|'bzip2')" | wc -l) -eq 1 ]
	then
		tar xf $archive -C $adir/
		line="$line 1"	
	elif [ $(file -b $archive | egrep 'Zip' | wc -l) -eq 1 ]
	then
		unzip -q $archive -d $adir/
		line="$line 1"
	elif [ $(file -b $archive | grep 'RAR' | wc -l) -eq 1 ]
	then
		unrar -y x $archive $adir/
		line="$line 1"
	else
		mkdir $bdir/$fn
		mv $archive $bdir/$fn/
		line="$line 1"
	fi
	
	
	echo $archive $line
	
	#echo $line
	#echo "{line}" >> $result
done


