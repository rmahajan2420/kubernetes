################################################################################
### This is a deployment script ################################################
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
#image=$3
containers=$4
aws s3 cp s3://fameplus-qa-private/docker/tag.txt .
tag=`cat tag.txt`

#usage(){
#  echo -e "\033[1;4m$0: Usage error. Usage: \033[0m"
#  echo -e "${0} ${LIGHTPURPLE_UL} Execute the script as SVC-WEPW user" 
#  echo -e "${0} ${LIGHTGREEN} -f ${GREEN_UL}INPUTFILEPATH ${NOCOLOUR} ${LIGHTGREEN}-e ${GREEN_UL}ENVIORNMENT PARAMETER${NOCOLOUR}"
#  echo -e "${LIGHTPURPLE_UL}INPUTFILEPATH${NOCOLOUR}${CYAN} is the full disk path of the ${RED_UL}tar.gz file" 
#  echo -e "${LIGHTPURPLE_UL}ENVIORNMENT PARAMETER ${NOCOLOUR} ${CYAN} can have one of these DEV/SYS/UAT/PREPROD values ${NOCOLOUR}"
#  exit 1
#}


if [ $# != 4 ]; then
$ECHO "Please Enter ENV name, Module, Image and number of containers"
exit
fi

filename=$env"_"$module.yaml
$ECHO  "Generating $env_$module.yaml file"

if [ $containers = '1' ]; then
  $SED -e "s/SERVER/$env/g; s/APP/$module/g; s/IMAGE/$image/g" template_1cont.yaml > $filename
elif [ $containers = '2' ]; then
  $SED -e "s/SERVER/$env/g; s/APP/$module/g; s/IMAGE/$image/g" template_2cont.yaml > $filename
fi

$ECHO "Deploying Module $module on Env $env with Version $image"
$KUBECTL apply -f $FILEPATH/$filename
