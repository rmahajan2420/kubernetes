################################################################################
### This is a rollback script ################################################
### It will ask for parameters such as env1ironment name, module #################
### based on the inputs it will generate a yaml deployment file on the fly #####
### and then calls the kubectl api to do the deployment #########################
#################################################################################


#!/bin/bash
SED=`which sed`
KUBECTL=`which kubectl`
FILEPATH=/root/kube_files/kubernetes/final/script
YAMLFILEPATH=/root/kube_files/kubernetes/final/script_yamls
ECHO=`which echo`
AWS=`which aws`
env1=$1
module=$2

cd $YAMLFILEPATH
if [ $env1 == qa ] 
then 
BUCKET_NAME=fameplus-qa-private
$AWS s3 cp s3://${BUCKET_NAME}/docker/tag.txt .
elif [ $env1 == uat ]
then
BUCKET_NAME=fameplus-uat-2
$AWS s3 cp s3://${BUCKET_NAME}/kubernetes/${module}/$env1"_"$module"_prev_tag".txt tag.txt --region us-east-1
else

echo "Invalid Env Name. Please enter qa or uat "
exit 1
fi
tag=`cat tag.txt`
if [ -z "$tag" ]
then
echo "################No previous tag file found on this location s3://${BUCKET_NAME}/kubernetes/${module}/$env1"_"$module"_prev_tag".txt .....Exiting !!! "
exit 1
fi



if [ $# != 2 ]; then
$ECHO "Please Enter ENV name, Module, Image and number of containers"
exit
fi

filename=$env1"_"$module.yaml
$ECHO  "Generating" $env1"_"$module.yaml





#Checking if module  exists in the appWithNginx.txt
grep -i "$module" $FILEPATH/appWithNginx.txt >> /dev/null

if [ $? -ne 0 ]; then
  $SED -e "s/SERVER/$env1/g; s/APP/$module/g; s/IMAGE/$tag/g" $FILEPATH/template_1cont.yaml > $YAMLFILEPATH/$filename
else
  $SED -e "s/SERVER/$env1/g; s/APP/$module/g; s/IMAGE/$tag/g" $FILEPATH/template_2cont.yaml > $YAMLFILEPATH/$filename
fi

$ECHO "Deploying Module $module on Env $env1 with Version $image"
$KUBECTL apply -f $YAMLFILEPATH/$filename
