#!/bin/bash

# set -e

#https://github.com/aws-samples/aws-do-eks
#https://github.com/aws-samples/aws-do-eks/tree/main/Container-Root/eks/ops/setup

download_and_verify () {
  url=$1
  checksum=$2
  out_file=$3

  curl --location --show-error --silent --output $out_file $url

  echo "$checksum $out_file" > "$out_file.sha256"
  sha256sum --check "$out_file.sha256"
  
  rm "$out_file.sha256"
}

cd /tmp/


echo "==============================================="
echo "  Install jq, envsubst (from GNU gettext utilities) and bash-completion ......"
echo "==============================================="
# 放在最前面，后续提取字段需要用到 jq
# moreutils: The command sponge allows us to read and write to the same file (cat a.txt|sponge a.txt)
sudo yum -y install jq gettext bash-completion moreutils tree zsh


echo "==============================================="
echo "  Config envs ......"
echo "==============================================="
export AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bashrc
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bashrc
aws configure set default.region ${AWS_REGION}
aws configure get default.region
aws configure set region $AWS_REGION
export EKS_VPC_ID=$(aws eks describe-cluster --name ${EKS_CLUSTER_NAME} --query 'cluster.resourcesVpcConfig.vpcId' --output text)
export EKS_VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids $EKS_VPC_ID --query 'Vpcs[0].{CidrBlock:CidrBlock}' --output text)

# export EKS_PUB_SUBNET_01=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${EKS_VPC_ID}" "Name=availability-zone, Values=${AWS_REGION}a" --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' --output text)
# export EKS_PRI_SUBNET_01=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${EKS_VPC_ID}" "Name=availability-zone, Values=${AWS_REGION}a" --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId' --output text)
# public 子网 注意 filter 区分大小写
EKS_PUB_SUBNET_LIST=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${EKS_VPC_ID}"  "Name=tag:Name,Values=*ublic*" | jq '.Subnets | sort_by(.AvailabilityZone)' | jq '.[] .SubnetId')
SUB_IDX=1
for subnet in $EKS_PUB_SUBNET_LIST
do
	#export EKS_PUB_SUBNET_$SUB_IDX=$(echo "$subnet" | tr -d '"') # 去掉双引号
	echo "export EKS_PUB_SUBNET_$SUB_IDX=$subnet" >> ~/.bashrc
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
echo "export EKS_OIDC_URL=${EKS_OIDC_URL}" | tee -a ~/.bashrc
source ~/.bashrc
aws sts get-caller-identity


echo "==============================================="
echo "  Install c9 to open files in cloud9 ......"
echo "==============================================="
npm install -g c9  # Install c9 to open files in cloud9 
# aws cloud9 update-environment --environment-id $C9_PID --managed-credentials-action DISABLE
# rm -vf ${HOME}/.aws/credentials
# example  c9 open ~/package.json


echo "==============================================="
echo "  Upgrade awscli to v2 ......"
echo "==============================================="
sudo mv /bin/aws /bin/aws1
sudo mv ~/anaconda3/bin/aws ~/anaconda3/bin/aws1
ls -l /usr/local/bin/aws
rm -fr awscliv2.zip aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install
which aws_completer
echo $SHELL
cat >> ~/.bashrc <<EOF
complete -C '/usr/local/bin/aws_completer' aws
EOF
source ~/.bashrc
aws --version
# container way
# https://aws.amazon.com/blogs/developer/new-aws-cli-v2-docker-images-available-on-amazon-ecr-public/
# docker run --rm -it public.ecr.aws/aws-cli/aws-cli:2.9.1 --version aws-cli/2.9.1 Python/3.9.11 Linux/5.10.47-linuxkit docker/aarch64.amzn.2 prompt/off
# Mac
# curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
# sudo installer -pkg /tmp/AWSCLIV2.pkg -target /
# which aws
# aws --version
# rm -fr /tmp/AWSCLIV2.pkg


echo "==============================================="
echo "  Install awscurl ......"
echo "==============================================="
# https://github.com/okigan/awscurl
cat >> ~/.bashrc <<EOF
export PATH=\$PATH:\$HOME/.local/bin:\$HOME/bin:/usr/local/bin
EOF
source ~/.bashrc
sudo python3 -m pip install awscurl


echo "==============================================="
echo "  Install eksctl ......"
echo "==============================================="
# curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
ARCH=amd64 # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" 
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
# 配置自动完成
cat >> ~/.bashrc <<EOF
. <(eksctl completion bash)
alias e=eksctl
complete -F __start_eksctl e
EOF


echo "==============================================="
echo "  Install kubectl ......"
echo "==============================================="
# 安装 kubectl 并配置自动完成
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
cat >> ~/.bashrc <<EOF
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
EOF
source ~/.bashrc
kubectl version --client
# Enable some kubernetes aliases
echo "alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L node.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone'" | tee -a ~/.bashrc
echo "alias kk='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L karpenter.sh/capacity-type -L node.kubernetes.io/instance-type -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name'" | tee -a ~/.bashrc
echo "alias kgp='kubectl get po -o wide'" | tee -a ~/.bashrc
echo "alias kgd='kubectl get deployment -o wide'" | tee -a ~/.bashrc
echo "alias kgs='kubectl get svc -o wide'" | tee -a ~/.bashrc
echo "alias kdn='kubectl describe node'" | tee -a ~/.bashrc
echo "alias kdp='kubectl describe po'" | tee -a ~/.bashrc
echo "alias kdd='kubectl describe deployment'" | tee -a ~/.bashrc
echo "alias kds='kubectl describe svc'" | tee -a ~/.bashrc
echo 'export dry="--dry-run=client -o yaml"' | tee -a ~/.bashrc
echo "alias ka='kubectl apply -f'" | tee -a ~/.bashrc
echo "alias kr='kubectl run $dry'" | tee -a ~/.bashrc
echo "alias ke='kubectl explain'" | tee -a ~/.bashrc
echo "alias tk='kt -n karpenter deploy/karpenter'" | tee -a ~/.bashrc # tail karpenter
echo "alias tl='kt -n kube-system deploy/aws-load-balancer-controller '" | tee -a ~/.bashrc # tail lbc
echo "alias pk='k patch configmap config-logging -n karpenter --patch'" | tee -a ~/.bashrc
# k patch configmap config-logging -n karpenter --patch 
# pk '{"data":{"loglevel.controller":"info"}}'
# k get po -l app.kubernetes.io/name=aws-node -n kube-system -o wide
source ~/.bashrc


echo "==============================================="
echo "  Install krew ......"
echo "==============================================="
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
cat >> ~/.bashrc <<EOF
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
EOF
source ~/.bashrc
kubectl krew update
kubectl krew install ingress-nginx
kubectl ingress-nginx --help
kubectl krew install resource-capacity
kubectl krew install count
kubectl krew install get-all
kubectl krew install ktop
kubectl krew install ctx # kubectx
kubectl krew install ns # kubens
kubectl krew install nodepools # https://github.com/grafana/kubectl-nodepools
kubectl krew install colorize-applied
kubectl krew install bulk-action
kubectl nodepools list
# kubectl krew install lineage
#kubectl krew install custom-cols
#kubectl krew install explore
#kubectl krew install flame
#kubectl krew install foreach
#kubectl krew install fuzzy
#kubectl krew index add kvaps https://github.com/kvaps/krew-index
#kubectl krew install kvaps/node-shell
kubectl krew list
# k resource-capacity --util --sort cpu.util # 查看节点
# k resource-capacity --pods --util --pod-labels app.kubernetes.io/name=aws-node --namespace kube-system --sort cpu.util
# k get po -l app.kubernetes.io/name=aws-node -n kube-system -o wide
kubectl resource-capacity -n kube-system -p -c
# kubectl ktop
# kubectl ktop -n default
# kubectl lineage --version
# k get-all
# k count pod
# k node-shell <node>
kubectl plugin list
# git clone https://github.com/surajincloud/kubectl-eks.git
# cd kubectl-eks
# make
# sudo mv ./kubectl-eks /usr/local/bin
# cd ..
# kubectl krew index add surajincloud git@github.com:surajincloud/krew-index.git
# kubectl krew search eks
# kubectl krew install surajincloud/kubectl-eks
# https://surajincloud.github.io/kubectl-eks/usage/
# kubectl eks irsa
# kubectl eks irsa -n kube-system
# kubectl eks ssm <name-of-the-node>
# kubectl eks nodes
# kubectl eks suggest-ami


echo "==============================================="
echo "  Install helm ......"
echo "==============================================="
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version
helm repo add stable https://charts.helm.sh/stable


echo "==============================================="
echo "  Install k9s a Kubernetes CLI To Manage Your Clusters In Style ......"
echo "==============================================="
# 参考 https://segmentfault.com/a/1190000039755239
curl -sS https://webinstall.dev/k9s | bash


echo "==============================================="
echo "  K10 ......"
echo "==============================================="
# https://docs.kasten.io/latest/install/aws/aws.html


echo "==============================================="
echo "  Config Go ......"
echo "==============================================="
go version
export GOPATH=$(go env GOPATH)
echo 'export GOPATH='${GOPATH} >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc


echo "==============================================="
echo "  Install kubetail ......"
echo "==============================================="
curl -o /tmp/kubetail https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
chmod +x /tmp/kubetail
sudo mv /tmp/kubetail /usr/local/bin/kubetail
cat >> ~/.bashrc <<EOF
alias kt=kubetail
EOF
source ~/.bashrc


echo "==============================================="
echo "  Install ec2-instance-selector ......"
echo "==============================================="
# https://github.com/aws/amazon-ec2-instance-selector
curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.4.1/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
chmod +x ./ec2-instance-selector
mkdir -p $HOME/bin && mv ./ec2-instance-selector $HOME/bin/ec2-instance-selector
cat >> ~/.bashrc <<EOF
alias nsel=ec2-instance-selector
EOF
source ~/.bashrc
nsel --version
# nsel --efa-support --gpu-memory-total-min 80 -r us-west-2 -o table-wide
# nsel --efa-support --gpus 0 -r us-west-2 -o table-wide
# ec2-instance-selector --memory 4 --vcpus 2 --cpu-architecture x86_64 -r us-east-1
# ec2-instance-selector --network-performance 100 --usage-class spot -r us-east-1
# ec2-instance-selector --memory 4 --vcpus 2 --cpu-architecture x86_64 -r us-east-1 -o table
# ec2-instance-selector -r us-east-1 -o table-wide --max-results 10 --sort-by memory --sort-direction asc
# ec2-instance-selector -r us-east-1 -o table-wide --max-results 10 --sort-by .MemoryInfo.SizeInMiB --sort-direction desc
# ec2-instance-selector --max-results 1 -v
# ec2-instance-selector -o interactive


echo "==============================================="
echo "  EKS Node Logs Collector (Linux) ......"
echo "==============================================="
# run this script on your eks node
sudo curl -o /usr/local/bin/nlog https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/log-collector-script/linux/eks-log-collector.sh
sudo chmod +x /usr/local/bin/nlog
nlog help


echo "==============================================="
echo "  Install eks-node-viewer ......"
echo "==============================================="
#https://github.com/awslabs/eks-node-viewer
go env -w GOPROXY=direct
go install github.com/awslabs/eks-node-viewer/cmd/eks-node-viewer@latest
export GOBIN=${GOBIN:-~/go/bin}
echo "export PATH=\$PATH:$GOBIN" >> ~/.bashrc
cat >> ~/.bashrc <<EOF
alias nfee='eks-node-viewer'
EOF
source ~/.bashrc
nfee -h


echo "==============================================="
echo " node-latency-for-k8s ......"
echo "==============================================="
# https://github.com/awslabs/node-latency-for-k8s
[[ `uname -m` == "aarch64" ]] && ARCH="arm64" || ARCH="amd64"
OS=`uname | tr '[:upper:]' '[:lower:]'`
wget https://github.com/awslabs/node-latency-for-k8s/releases/download/v0.1.10/node-latency-for-k8s_0.1.10_${OS}_${ARCH}.tar.gz -O /tmp/node-latency-for-k8s.tar.gz
sudo mkdir -p /opt/node-latency-for-k8s
sudo tar xzvf /tmp/node-latency-for-k8s.tar.gz -C /opt/node-latency-for-k8s
chmod +x /opt/node-latency-for-k8s/node-latency-for-k8s
cat >> ~/.bashrc <<EOF
export PATH="/opt/node-latency-for-k8s:$PATH"
alias nlag='node-latency-for-k8s'
EOF
source ~/.bashrc
nlag -h


echo "==============================================="
echo "  EKS Pod Information Collector ......"
echo "==============================================="
# https://github.com/awslabs/amazon-eks-ami/tree/master/log-collector-script/linux
sudo curl -o /usr/local/bin/epic https://raw.githubusercontent.com/aws-samples/eks-pod-information-collector/main/eks-pod-information-collector.sh
sudo chmod +x /usr/local/bin/epic
# epic -p <Pod_Name> -n <Pod_Namespace>
# epic --podname <Pod_Name> --namespace <Pod_Namespace>


echo "==============================================="
echo "  Install session-manager ......"
echo "==============================================="
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "/tmp/session-manager-plugin.rpm"
sudo yum install -y /tmp/session-manager-plugin.rpm
session-manager-plugin
# Mac
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "/tmp/sessionmanager-bundle.zip"
unzip /tmp/sessionmanager-bundle.zip -d /tmp
sudo /tmp/sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
rm -fr /tmp/sessionmanager-bundle*


echo "==============================================="
echo "  Install yq for yaml processing ......"
echo "==============================================="
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq
# echo 'yq() {
#   docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
# }' | tee -a ~/.bashrc && source ~/.bashrc


echo "==============================================="
echo "  Install wildq ......"
echo "==============================================="
# wildq: Tool on-top of jq to manipulate INI files
sudo pip3 install wildq
# cat file.ini \
#   |wildq -i ini -M '.Key = "value"' \
#   |sponge file.ini


echo "==============================================="
echo "  Install Java ......"
echo "==============================================="
# sudo amazon-linux-extras enable corretto8
# sudo yum clean metadata
# sudo yum install java-1.8.0-amazon-corretto-devel -y
sudo yum -y install java-11-amazon-corretto
#sudo alternatives --config java
#sudo update-alternatives --config javac
java -version
javac -version


echo "==============================================="
echo "  Performance Test ......"
echo "==============================================="
# siege
sudo yum install siege -y
siege -V
#siege -q -t 15S -c 200 -i URL
#ab -c 500 -n 30000 http://$(kubectl get ing -n front-end --output=json | jq -r .items[].status.loadBalancer.ingress[].hostname)/
# storage
sudo yum install fio ioping -y
## FIO command to perform load testing, and write down the IOPS and Throughput
# mkdir -p /data/performance
# cd /data/performance
# fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=fiotest --filename=testfio8gb --bs=1MB --iodepth=64 --size=8G --readwrite=randrw --rwmixread=50 --numjobs=4 --group_reporting --runtime=30
# IOping to test the latency
# sudo ioping -c 100 /efs


echo "==============================================="
echo "  Network Utilites ......"
echo "==============================================="
#https://repost.aws/knowledge-center/network-issue-vpc-onprem-ig
sudo yum -y install telnet mtr traceroute


echo "==============================================="
echo "  Cofing dfimage ......"
echo "==============================================="
cat >> ~/.bashrc <<EOF
alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage"  
EOF
source ~/.bashrc
# dfimage -sV=1.36 nginx:latest 


echo "==============================================="
echo " dos2unix ......"
echo "==============================================="
sudo yum install dos2unix -y
# dos2unix xxx.sh


echo "==============================================="
echo " s5cmd ......"
echo "==============================================="
#https://github.com/peak/s5cmd
export S5CMD_URL=$(curl -s https://api.github.com/repos/peak/s5cmd/releases/latest \
| grep "browser_download_url.*_Linux-64bit.tar.gz" \
| cut -d : -f 2,3 \
| tr -d \")
# echo $S5CMD_URL
wget $S5CMD_URL -O /tmp/s5cmd.tar.gz
sudo mkdir -p /opt/s5cmd/
sudo tar xzvf /tmp/s5cmd.tar.gz -C /opt/s5cmd
cat >> ~/.bashrc <<EOF
export PATH="/opt/s5cmd:$PATH"
EOF
source ~/.bashrc
s5cmd version


echo "==============================================="
echo "  Expand disk space ......"
echo "==============================================="
wget https://raw.githubusercontent.com/DATACNTOP/streaming-analytics/main/utils/scripts/resize-ebs.sh -O /tmp/resize-ebs.sh
chmod +x /tmp/resize-ebs.sh
/tmp/resize-ebs.sh 100


echo "==============================================="
echo "  More Aliases ......"
echo "==============================================="
# .vimrc
cat > ~/.vimrc <<EOF
set number
set expandtab
set tabstop=2
set shiftwidth=2
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
EOF
# .bashrc
cat >> ~/.bashrc <<EOF
alias c=clear
alias ll='ls -alh --color=auto'
alias jc=/bin/journalctl
export TERM=xterm-256color
EOF
source ~/.bashrc
# journalctl -u kubelet | grep error 
# 最后再执行一次 source
echo "source .bashrc"
shopt -s expand_aliases
source ~/.bashrc