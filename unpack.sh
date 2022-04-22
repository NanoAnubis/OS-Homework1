#!/bin/bash

zip=$1
adir=$2
bdir=$3
result=$4

tmp=$(mktemp -d)

#mkdir $adir
#mkdir $bdir
#touch $result

unzip "${zip}" -d "${tmp}"

