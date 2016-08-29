################################################################################
### This is a deployment script ################################################
### It will ask for parameters such as env1ironment name, module #################
### based on the inputs it will generate a yaml deployment file on the fly #####
### and then calls the kubectl api to do the deployment #########################
#################################################################################


#!/bin/bash
SED=`which sed`
KUBECTL=`which kubectl`
FILEPATH=/root/kube_files/kubernetes/final/script
ECHO=`which echo`
AWS=`which aws`
env1=$1
module=$2
$AWS s3 cp s3://fameplus-qa-private/docker/tag.txt .
tag=`cat tag.txt`


if [ $# != 2 ]; then
$ECHO "Please Enter ENV name, Module, Image and number of containers"
exit
fi

filename=$env1"_"$module.yaml
$ECHO  "Generating" $env1"-"$module.yaml

#Checking if module  exists in the appWithNginx.txt
grep -i "$module" $FILEPATH/appWithNginx.txt >> /dev/null

if [ $? -ne 0 ]; then
  $SED -e "s/SERVER/$env1/g; s/APP/$module/g; s/IMAGE/$tag/g" $FILEPATH/template_1cont.yaml > $filename
else
  $SED -e "s/SERVER/$env1/g; s/APP/$module/g; s/IMAGE/$tag/g" $FILEPATH/template_2cont.yaml > $filename
fi

$ECHO "Deploying Module $module on Env $env1 with Version $image"
$KUBECTL apply -f $FILEPATH/$filename
