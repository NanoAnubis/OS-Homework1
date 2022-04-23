#!/bin/bash

rm -r $2 $3 $4


zip=$1
adir=$2
bdir=$3
result=$4

tmp=$(mktemp -d)

mkdir $adir
mkdir $bdir
touch $result
r=$(mktemp)

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
	
	#extract archive in temp directory

	archive="$d/$archive"
	t=$(mktemp -d)		

	if [ $(file -b $archive | egrep 'XZ' | wc -l) -eq 1 ] 
	then	
		tar xf $archive -C $t/ 2>/dev/null
		line="$line 0"
	elif [ $(file -b $archive | egrep "(tar|gzip|bzip2)" | wc -l) -eq 1 ]
	then
		tar xf $archive -C $t/ 2>/dev/null
		line="$line 1"	
	elif [ $(file -b $archive | egrep 'Zip' | wc -l) -eq 1 ]
	then
		unzip -q $archive -x '__MACOSX/*' -d $t/ 2>/dev/null
		line="$line 1"
	elif [ $(file -b $archive | grep 'RAR' | wc -l) -eq 1 ]
	then
		unrar -y x $archive $t/ -idq 2>/dev/null
		line="$line 1"
	else
		mkdir $bdir/$fn
		mv $archive $bdir/$fn/
		continue
	fi 
	
	#check for directory and its name

	if [ $(find $t -mindepth 1 -type d | wc -l) -eq 1 ]	
	then
		line="$line 0"
		if [ "$(find $t -mindepth 1 -maxdepth 1 -type d)" = "$t/$fn" ]
		then
			line="$line 0"
		else
			line="$line 1"
			mv $(find $t -mindepth 1 -maxdepth 1 -type d) $t/$fn
		fi
		
		cp -r $t/$fn $adir/	
	elif [ $(find $t -mindepth 1 -type d | wc -l) -gt 1 ]
	then
		line="$line 0"
		echo "$fn"
		if [ "$(find $t -type d | head -n 1 | cut -d '/' -f 1)" = $fn ]
		then
			line="$line 0"


		else
			line="$line 1"

		fi
		mv $(find $t -type d | tail -n 1) $t/$fn
		cp -r $t/$fn $adir/	
	else
		line="$line 1 1"
		mkdir $adir/$fn
		cp -r $t/* $adir/$fn/ 2>/dev/null
	fi
	
	rm -r $t
	echo "$line" >> $r
done

#rm -r $tmp

cat $r | sort -n > $result


