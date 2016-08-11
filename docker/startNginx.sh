#!/bin/bash
BUCKET=blank
if [ $ENV_NAME = 'qa' ]
        then
        BUCKET=fameplus-qa-private

elif [ $ENV_NAME = 'production' ]
        then
        BUCKET=fameplus-production

elif [ $ENV_NAME = 'uat' ]
        then
        BUCKET=fameplus-uat-2

elif [ $ENV_NAME = 'load' ]
        then
        BUCKET=fameplus-load

elif [ $ENV_NAME = 'qa1' ]
        then
        BUCKET=fame-qa1
fi
AWS=`which aws`
$AWS s3 cp s3://${BUCKET}/kubernetes/${MODULE}/nginx/conf/${ENV_NAME}-${MODULE}.conf /etc/nginx/sites-enabled/ --region us-east-1
service nginx restart
tailf /dev/null

