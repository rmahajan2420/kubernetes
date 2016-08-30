#!/bin/bash
#cd master
K8SMASTERNAME=fame-kubernetes-aws-master
K8SMINIONNAME=fame-kubernetes-aws-minion
AWS="/usr/local/bin/aws"

#K8SMASTERID=$($AWS ec2 describe-instances --region 'us-east-1' --filters Name=tag:Name,Values=$K8SMASTERNAME --query 'Reservations[].Instances[].[InstanceId]' --output text | sed '$!N;s/\n/ /' | awk '{print $1}')
K8SMASTERID=$($AWS ec2 describe-instances --region 'us-east-1' --filters Name=tag:Name,Values=$K8SMASTERNAME --query 'Reservations[].Instances[].[InstanceId]' --output text)


#K8SMINIONID=$($AWS ec2 describe-instances --region 'us-east-1' --filters Name=tag:Name,Values=$K8SMINIONNAME --query 'Reservations[].Instances[].[InstanceId]' --output text | sed '$!N;s/\n/ /' | awk '{print $1}')
K8SMINIONID=$($AWS ec2 describe-instances --region 'us-east-1' --filters Name=tag:Role,Values=$K8SMINIONNAME Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[InstanceId]' --output text )

#SUBNETID=$($AWS ec2 describe-instances --region 'us-east-1' --filters Name=tag:Role,Values=$K8SMINIONNAME --query 'Reservations[].Instances[].[SubnetId]' --output text | sed '$!N;s/\n/ /' | awk '{print $1}')

SUBNET_IDs=($($AWS ec2 describe-instances --region 'us-east-1' --filters Name=tag:Role,Values=$K8SMINIONNAME --query 'Reservations[].Instances[].[SubnetId]' --output text))

ROUTETABLEID=($($AWS ec2 describe-route-tables --region us-east-1 --query 'RouteTables[*].Associations[*].RouteTableId[]' --filters "Name=association.subnet-id,Values=${SUBNET_IDs[2]}" --output text))


echo "Master" $K8SMASTERID
echo "Minion" $K8SMINIONID
echo "Subnet Id" ${SUBNET_IDs[1]}
echo "RouteTB ID" ${ROUTETABLEID[1]}

#kubectl describe nodes/$(kubectl get nodes | tail -1 | awk '{print $1}') | grep PodCIDR | awk '{print $2}'

/usr/local/bin/kubectl get nodes | tail -n +2 | awk '{print $1}' > available_nodes

for i in `cat available_nodes`
do
echo $K8SMINIONID
        DESTINATION_BLOCK=$(/usr/local/bin/kubectl describe nodes/$i | grep PodCIDR | awk '{print $2}')
        K8SMINIONID=$(/usr/local/bin/kubectl describe nodes/$i | grep ExternalID | awk '{print $2}')
        $AWS ec2 create-route --region 'us-east-1' --route-table-id ${ROUTETABLEID[1]} --destination-cidr-block $DESTINATION_BLOCK --instance-id $K8SMINIONID
done
# Master Entry
#$AWS ec2 create-route --route-table-id $ROUTETABLEID --destination-cidr-block 20.246.0.0/16 --instance-id $K8SMASTERID
