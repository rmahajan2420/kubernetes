#!/bin/bash
mkdir -p /opt/script/
cd /opt/script
wget https://s3.amazonaws.com/fameplus-kubernetes/aws-userdata/prod/userdata-spot-prod.sh -O-|sudo bash
