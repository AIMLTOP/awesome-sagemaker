#!/bin/bash

echo "==============================================="
echo "  Config envs ......"
echo "==============================================="
export AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AZS=($(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text --region $AWS_REGION))
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bashrc
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bashrc
echo "export AZS=${AZS}" | tee -a ~/.bashrc
aws configure set default.region ${AWS_REGION}
aws configure get default.region
aws configure set region $AWS_REGION
export EKS_VPC_ID=$(aws eks describe-cluster --name ${EKS_CLUSTER_NAME} --query 'cluster.resourcesVpcConfig.vpcId' --output text)
export EKS_VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids $EKS_VPC_ID --query 'Vpcs[0].{CidrBlock:CidrBlock}' --output text)
# export EKS_PUB_SUBNET_01=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${EKS_VPC_ID}" "Name=availability-zone, Values=${AWS_REGION}a" --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' --output text)
# export EKS_PRI_SUBNET_01=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${EKS_VPC_ID}" "Name=availability-zone, Values=${AWS_REGION}a" --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId' --output text)
# public 子网 注意 filter 区分大小写
# EKS_PUB_SUBNET_LIST=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${EKS_VPC_ID}"  "Name=tag:Name,Values=*ublic*" | jq '.Subnets | sort_by(.AvailabilityZone)' | jq '.[] .SubnetId')
# SUB_IDX=1
# for subnet in $EKS_PUB_SUBNET_LIST
# do
# 	#export EKS_PUB_SUBNET_$SUB_IDX=$(echo "$subnet" | tr -d '"') # 去掉双引号
# 	echo "export EKS_PUB_SUBNET_$SUB_IDX=$subnet" >> ~/.bashrc
# 	((SUB_IDX++))
# done
EKS_PUBAZ_INFO_LIST=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${EKS_VPC_ID}"  "Name=tag:Name,Values=*ublic*" | jq '.Subnets | sort_by(.AvailabilityZone)' | jq '.[] | .SubnetId+","+.AvailabilityZone+","+.AvailabilityZoneId')
SUB_IDX=1
for pubazinfo in $EKS_PUBAZ_INFO_LIST
do
	export info_str=$(echo "$pubazinfo" | tr -d '"') # 去掉双引号
  IFS=',' read -ra info_array <<< "$info_str"
	echo "export EKS_PUB_SUBNET_$SUB_IDX=${info_array[0]}" >> ~/.bashrc
	echo "export EKS_AZ_$SUB_IDX=${info_array[1]}" >> ~/.bashrc
	echo "export EKS_AZ_ID_$SUB_IDX=${info_array[2]}" >> ~/.bashrc
	((SUB_IDX++))
done
# private 子网
EKS_PRI_SUBNET_LIST=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${EKS_VPC_ID}"  "Name=tag:Name,Values=*rivate*" "Name=cidr-block,Values=*$(echo $EKS_VPC_CIDR | cut -d . -f 1).$(echo $EKS_VPC_CIDR | cut -d . -f 2).*" | jq '.Subnets | sort_by(.AvailabilityZone)' | jq '.[] .SubnetId')
SUB_IDX=1
for subnet in $EKS_PRI_SUBNET_LIST
do
	echo "export EKS_PRI_SUBNET_$SUB_IDX=$subnet" >> ~/.bashrc
	((SUB_IDX++))
done
# pod 子网
EKS_POD_SUBNET_LIST=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${EKS_VPC_ID}"  "Name=tag:Name,Values=*rivate*" "Name=cidr-block,Values=*100.64.*" | jq '.Subnets | sort_by(.AvailabilityZone)' | jq '.[] .SubnetId')
SUB_IDX=1
for subnet in $EKS_POD_SUBNET_LIST
do
	echo "export EKS_POD_SUBNET_$SUB_IDX=$subnet" >> ~/.bashrc
	((SUB_IDX++))
done
# Additional security groups
export EKS_EXTRA_SG=$(aws eks describe-cluster --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME} | jq -r '.cluster.resourcesVpcConfig.securityGroupIds[0]')
# Cluster security group
export EKS_CLUSTER_SG=$(aws eks describe-cluster --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME} | jq -r '.cluster.resourcesVpcConfig.clusterSecurityGroupId')
# Share node security group
export EKS_SHAREDNODE_SG=$(aws ec2 describe-security-groups --filter Name=vpc-id,Values=$EKS_VPC_ID --filter Name=group-name,Values=*ClusterSharedNode* | jq -r '.SecurityGroups[]|.GroupId')  
if [ -z "$EKS_SHAREDNODE_SG" ]
then
      echo "\$EKS_SHAREDNODE_SG is empty, try with ${EKS_CLUSTER_NAME}-node style "
      export EKS_SHAREDNODE_SG=$(aws ec2 describe-security-groups --filter Name=vpc-id,Values=$EKS_VPC_ID --filter Name=group-name,Values=*${EKS_CLUSTER_NAME}-node* | jq -r '.SecurityGroups[]|.GroupId')
fi
# EKS cluster has an OpenID Connect issuer URL associated with it. To use IAM roles for service accounts, an IAM OIDC provider must exist.
export EKS_OIDC_URL=$(aws eks describe-cluster --name ${EKS_CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text)
echo "export EKS_VPC_ID=\"$EKS_VPC_ID\"" >> ~/.bashrc
echo "export EKS_VPC_CIDR=\"$EKS_VPC_CIDR\"" >> ~/.bashrc
echo "export EKS_EXTRA_SG=${EKS_EXTRA_SG}" | tee -a ~/.bashrc
echo "export EKS_CLUSTER_SG=${EKS_CLUSTER_SG}" | tee -a ~/.bashrc
echo "export EKS_SHAREDNODE_SG=${EKS_SHAREDNODE_SG}" | tee -a ~/.bashrc
echo "export EKS_CUSTOMNETWORK_SG=" | tee -a ~/.bashrc
echo "export EKS_OIDC_URL=${EKS_OIDC_URL}" | tee -a ~/.bashrc
source ~/.bashrc
aws sts get-caller-identity


## Backup
# if [ $# -eq 0 ]
#   then
#     echo "Please provide CloudformationStackName"
#     return
# fi

# # 配置环境变量，方便后续操作
# echo "==============================================="
# echo "  Update CloudFormation Outputs to ENVs ......"
# echo "==============================================="
# export AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/')
# export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)

# test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set

# echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bashrc
# echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bashrc
# aws configure set default.region ${AWS_REGION}
# aws configure get default.region
# aws configure set region $AWS_REGION

# source ~/.bashrc
# aws sts get-caller-identity

# # 将CloudFormation的Output保存到环境变量，然后进一步记录到 `.bashrc`
# export $(aws cloudformation describe-stacks --stack-name $1 --output text --query 'Stacks[0].Outputs[].join(`=`, [join(`_`, [`CF`, `OUT`, OutputKey]), OutputValue ])' --region $AWS_REGION)
# echo "export EKS_VPC_ID=\"$CF_OUT_VpcId\"" >> ~/.bashrc
# echo "export EKS_CONTROLPLANE_SG=\"$CF_OUT_ControlPlaneSecurityGroup\"" >> ~/.bashrc
# echo "export EKS_SHAREDNODE_SG=\"$CF_OUT_SharedNodeSecurityGroup\"" >> ~/.bashrc
# echo "export EKS_CUSTOMNETWORK_SG=\"$CF_OUT_CustomNetworkSecurityGroup\"" >> ~/.bashrc
# echo "export EKS_EXTERNAL_SG=\"$CF_OUT_ExternalSecurityGroup\"" >> ~/.bashrc
# echo "export EKS_PUB_SUBNET_01=\"$CF_OUT_PublicSubnet1\"" >> ~/.bashrc
# echo "export EKS_PUB_SUBNET_02=\"$CF_OUT_PublicSubnet2\"" >> ~/.bashrc
# echo "export EKS_PUB_SUBNET_03=\"$CF_OUT_PublicSubnet3\"" >> ~/.bashrc
# echo "export EKS_PRI_SUBNET_01=\"$CF_OUT_PrivateSubnet1\"" >> ~/.bashrc
# echo "export EKS_PRI_SUBNET_02=\"$CF_OUT_PrivateSubnet2\"" >> ~/.bashrc
# echo "export EKS_PRI_SUBNET_03=\"$CF_OUT_PrivateSubnet3\"" >> ~/.bashrc
# echo "export EKS_POD_SUBNET_01=\"$CF_OUT_PodSubnet1\"" >> ~/.bashrc
# echo "export EKS_POD_SUBNET_02=\"$CF_OUT_PodSubnet2\"" >> ~/.bashrc
# echo "export EKS_POD_SUBNET_03=\"$CF_OUT_PodSubnet3\"" >> ~/.bashrc
# echo "export EKS_KEY_ARN=\"$CF_OUT_EKSKeyArn\"" >> ~/.bashrc
# echo "export EKS_ADMIN_ROLE=\"$CF_OUT_EKSAdminRole\"" >> ~/.bashrc



