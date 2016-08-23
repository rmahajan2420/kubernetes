#!/bin/bash
SED=`which sed`
env=$1
module=$2
image=$3

if [ $# != 3 ]; then
echo "Please Enter ENV name, Module and Image"
exit
fi

$SED -e "s/ENV_NAME/$env/g; s/MODULE/$module/g; s/IMAGE/$image/g" template.yaml > $env"-"$module.yaml

