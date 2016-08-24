################################################################################
### This deployment script  ####################################################
### It will ask for parameters such as environment name, module #################
### based on the inputs it will generate a yaml deployment file on the fly #####
### and then calls the kubectl api to do the deployment #########################
#################################################################################


#!/bin/bash
SED=`which sed`
KUBECTL=`which kubectl`
FILEPATH=/root/kube_files/kubernetes/final/script
ECHO=`which echo`
env=$1
module=$2
image=$3

if [ $# != 3 ]; then
echo "Please Enter ENV name, Module and Image"
exit
fi

$ECHO  "Generating $env_$module.yaml file"

$SED -e "s/ENV_NAME/$env/g; s/MODULE/$module/g; s/IMAGE/$image/g" template.yaml > $env"-"$module.yaml
filename=$env"-"$module.yaml


$ECHO "Deploying Module $module on Env $env with Version $image"
$KUBECTL apply -f $FILEPATH/$filename

