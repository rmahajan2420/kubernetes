#!/bin/bash
mkdir -p /opt/script/
cd /opt/script
wget https://s3.amazonaws.com/fameplus-kubernetes/aws-userdata/userdata-asg.sh -O-|sudo bash
