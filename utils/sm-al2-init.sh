#!/bin/bash

source ~/.bashrc

CUSTOM_DIR=/home/ec2-user/SageMaker/custom
if [ ! -d "$CUSTOM_DIR" ]; then
  echo "Set custom dir and bashrc"
  mkdir -p "$CUSTOM_DIR"/bin
  echo "export CUSTOM_DIR=${CUSTOM_DIR}" >> ~/SageMaker/custom/bashrc
  echo 'export PATH=$PATH:/home/ec2-user/SageMaker/custom/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin' >> ~/SageMaker/custom/bashrc
fi


echo "==============================================="
echo "  Load custom bashrc ......"
echo "==============================================="
# Add custom bash file if not set before
cat >> ~/.bashrc <<EOF
bashrc_files=(bashrc)
path="/home/ec2-user/SageMaker/custom/"
for file in \${bashrc_files[@]}
do 
    file_to_load=\$path\$file
    if [ -f "\$file_to_load" ];
    then
        . \$file_to_load
        echo "loaded \$file_to_load"
    fi
done
EOF

source ~/.bashrc

# check if a ENV ACCOUNT_ID exist
if [ -z ${ACCOUNT_ID} ]; then
  # create CUSTOM_BASH file
  echo "Add envs: ACCOUNT_ID AWS_REGION"
  cat >> ~/SageMaker/custom/bashrc <<EOF
export AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)

EOF
fi


echo "==============================================="
echo "  Utilities ......"
echo "==============================================="
# moreutils: The command sponge allows us to read and write to the same file (cat a.txt|sponge a.txt)
sudo amazon-linux-extras install epel -y
sudo yum groupinstall "Development Tools" -y
sudo yum -y install jq gettext bash-completion moreutils openssl tree zsh xsel xclip amazon-efs-utils nc telnet mtr traceroute netcat 
# sudo yum -y install siege fio ioping dos2unix

if [ ! -f $CUSTOM_DIR/bin/yq ]; then
  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O $CUSTOM_DIR/bin/yq
  chmod +x $CUSTOM_DIR/bin/yq
fi


# Upgrade awscli to v2
if [ ! -f $CUSTOM_DIR/bin/awscliv2.zip ]; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$CUSTOM_DIR/bin/awscliv2.zip"
  # unzip -qq awscliv2.zip -C
  unzip -o $CUSTOM_DIR/bin/awscliv2.zip -d $CUSTOM_DIR/bin
fi
sudo $CUSTOM_DIR/bin/aws/install --update
rm -f /home/ec2-user/anaconda3/envs/JupyterSystemEnv/bin/aws
sudo mv ~/anaconda3/bin/aws ~/anaconda3/bin/aws1
ls -l /usr/local/bin/aws
source ~/.bashrc
aws --version


# Install session-manager
if [ ! -f $CUSTOM_DIR/bin/session-manager-plugin.rpm ]; then
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "$CUSTOM_DIR/bin/session-manager-plugin.rpm"
fi
sudo yum install -y $CUSTOM_DIR/bin/session-manager-plugin.rpm
session-manager-plugin

# ec2-instance-selector
if [ ! -f $CUSTOM_DIR/bin/ec2-instance-selector ]; then
  target=$(uname | tr '[:upper:]' '[:lower:]')-amd64
  LATEST_DOWNLOAD_URL=$(curl --silent $CUSTOM_DIR/bin/ec2-instance-selector "https://api.github.com/repos/aws/amazon-ec2-instance-selector/releases/latest" | grep "\"browser_download_url\": \"https.*$target.tar.gz" | sed -E 's/.*"([^"]+)".*/\1/')
  curl -Lo $CUSTOM_DIR/bin/ec2-instance-selector.tar.gz $LATEST_DOWNLOAD_URL
  tar -xvf $CUSTOM_DIR/bin/ec2-instance-selector.tar.gz -C $CUSTOM_DIR/bin
  # curl -Lo $CUSTOM_DIR/bin/ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.4.1/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 
  chmod +x $CUSTOM_DIR/bin/ec2-instance-selector
fi


# S3 mountpoint
if [ ! -f $CUSTOM_DIR/bin/mount-s3.rpm ]; then
  wget -O $CUSTOM_DIR/bin/mount-s3.rpm https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm
fi
sudo yum install -y $CUSTOM_DIR/bin/mount-s3.rpm


# s5cmd
# https://github.com/peak/s5cmd
if [ ! -f $CUSTOM_DIR/bin/s5cmd ]; then
    echo "Setup s5cmd"
    S5CMD_URL="https://github.com/peak/s5cmd/releases/download/v2.2.2/s5cmd_2.2.2_Linux-64bit.tar.gz"
    wget $S5CMD_URL -O /tmp/s5cmd.tar.gz
    sudo mkdir -p /opt/s5cmd/
    sudo tar xzvf /tmp/s5cmd.tar.gz -C $CUSTOM_DIR/bin
fi
# mv/sync 等注意要加单引号，注意区域配置
# s5cmd mv 's3://xxx-iad/HFDatasets/*' 's3://xxx-iad/datasets/HF/'
# s5 --profile=xxx cp --source-region=us-west-2 s3://xxx.zip ./xxx.zip


# https://github.com/muesli/duf
echo "Setup duf"
if [ ! -f $CUSTOM_DIR/duf.rpm ]; then
    DOWNLOAD_URL="https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_amd64.rpm"
    wget $DOWNLOAD_URL -O $CUSTOM_DIR/duf.rpm
fi
sudo yum localinstall -y $CUSTOM_DIR/duf.rpm


echo "==============================================="
echo "  Container tools ......"
echo "==============================================="
ARCH=amd64 # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
PLATFORM=$(uname -s)_$ARCH
if [ ! -f $CUSTOM_DIR/bin/eksctl_$PLATFORM.tar.gz ]; then
  curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" -o $CUSTOM_DIR/bin/eksctl_$PLATFORM.tar.gz
  tar -xzf $CUSTOM_DIR/bin/eksctl_$PLATFORM.tar.gz -C $CUSTOM_DIR/bin
fi
if [ ! -f $CUSTOM_DIR/bin/eksctl_150.tar.gz ]; then
  curl -sL "https://github.com/eksctl-io/eksctl/releases/download/v0.150.0/eksctl_Linux_amd64.tar.gz" -o $CUSTOM_DIR/bin/eksctl_150.tar.gz
  tar -xzf $CUSTOM_DIR/bin/eksctl_150.tar.gz
  mv eksctl $CUSTOM_DIR/bin/eksctl150
fi

if [ ! -f $CUSTOM_DIR/bin/kubectl ]; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  mv kubectl /tmp/
  sudo install -o root -g root -m 0755 /tmp/kubectl $CUSTOM_DIR/bin/kubectl
fi

if [ ! -f $CUSTOM_DIR/bin/get_helm.sh ]; then
  curl -fsSL -o $CUSTOM_DIR/bin/get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod 700 $CUSTOM_DIR/bin/get_helm.sh
fi
$CUSTOM_DIR/bin/get_helm.sh
helm version
helm repo add eks https://aws.github.io/eks-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update
# docker logout public.ecr.aws
helm registry logout public.ecr.aws

if [ ! -f $CUSTOM_DIR/bin/kubectl-karpenter.sh ]; then
  curl -fsSL -o $CUSTOM_DIR/bin/kubectl-karpenter.sh https://raw.githubusercontent.com/TipTopBin/aws-do-eks/main/utils/kubectl-karpenter.sh
  chmod +x $CUSTOM_DIR/bin/kubectl-karpenter.sh
fi

curl -sS https://webinstall.dev/k9s | bash

if [ ! -f $CUSTOM_DIR/bin/kubetail ]; then
  curl -o $CUSTOM_DIR/bin/kubetail https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
  chmod +x $CUSTOM_DIR/bin/kubetail
fi

if [ ! -f $CUSTOM_DIR/bin/kustomize ]; then
  curl -s https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash
  sudo mv -v kustomize $CUSTOM_DIR/bin
fi
kustomize version

if [ ! -f $CUSTOM_DIR/bin/kubie ]; then
  wget https://github.com/sbstp/kubie/releases/latest/download/kubie-linux-amd64 -O $CUSTOM_DIR/bin/kubie
  chmod +x $CUSTOM_DIR/bin/kubie
fi


# krew
if [ ! -d $CUSTOM_DIR/bin/krew ]; then
  export KREW_ROOT="$CUSTOM_DIR/bin/krew"
  (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
  )

  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  kubectl krew update
  kubectl krew install ctx # kubectx
  kubectl krew install ns # kubens
fi


# # run this script on your eks node
# if [ ! -f $CUSTOM_DIR/bin/eks-log-collector.sh ]; then
#   curl -o $CUSTOM_DIR/bin/eks-log-collector.sh https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/log-collector-script/linux/eks-log-collector.sh 
#   chmod +x $CUSTOM_DIR/bin/eks-log-collector.sh
# fi

# AMI
# export ACCELERATED_AMI=$(aws ssm get-parameter \
#     --name /aws/service/eks/optimized-ami/$EKS_VERSION/amazon-linux-2-gpu/recommended/image_id \
#     --region $AWS_REGION \
#     --query "Parameter.Value" \
#     --output text)


# k8sgpt
if [ ! -f $CUSTOM_DIR/bin/k8sgpt_Linux_x86_64.tar.gz ]; then
  wget -O $CUSTOM_DIR/bin/k8sgpt_Linux_x86_64.tar.gz https://github.com/k8sgpt-ai/k8sgpt/releases/download/v0.3.25/k8sgpt_Linux_x86_64.tar.gz
  tar -xvf $CUSTOM_DIR/bin/k8sgpt_Linux_x86_64.tar.gz -C $CUSTOM_DIR/bin
fi
k8sgpt auth add --backend amazonbedrock --model anthropic.claude-v2
k8sgpt auth list
k8sgpt auth default -p amazonbedrock


# # Docker Compose
# #sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
# sudo mkdir -p /usr/local/lib/docker/cli-plugins/
# sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
# sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
# # sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o $CUSTOM_DIR/docker-compose
# # sudo chmod +x $CUSTOM_DIR/docker-compose
# # $CUSTOM_DIR/docker-compose version


echo "==============================================="
echo "  Load config ......"
echo "==============================================="
if [ ! -z "$EKS_CLUSTER_NAME" ]; then
    # aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}
    /usr/local/bin/aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}
fi


if [ -f /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_private_key.pem ]
then
  echo "Setup SSH Keys"
  sudo cp /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_private_key.pem ~/.ssh/id_rsa
  sudo cp /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_public_key.pem ~/.ssh/id_rsa.pub
  sudo chmod 400 ~/.ssh/id_rsa
  sudo chown -R ec2-user:ec2-user ~/.ssh/
  # ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub
fi


# sagemaker-hyperpod ssh
# https://catalog.workshops.aws/sagemaker-hyperpod/en-US/01-cluster/05-ssh
if [ ! -f $CUSTOM_DIR/bin/easy-ssh ]; then
  wget -O $CUSTOM_DIR/bin/easy-ssh https://raw.githubusercontent.com/TipTopBin/awesome-distributed-training/main/1.architectures/5.sagemaker-hyperpod/easy-ssh.sh
  chmod +x $CUSTOM_DIR/bin/easy-ssh
fi
# easy-ssh -h
# easy-ssh -c controller-group cluster-name


# S3 bucket
# mount-s3 [OPTIONS] <BUCKET_NAME> <DIRECTORY>
if [ ! -z "$S3_INTG_AUTO" ]; then
    mkdir -p /home/ec2-user/SageMaker/s3/${S3_INTG_AUTO}
    mount-s3 ${S3_INTG_AUTO} /home/ec2-user/SageMaker/s3/${S3_INTG_AUTO} --allow-other --allow-delete --dir-mode 777
    # sudo mount-s3 ${HP_S3_BUCKET} $HP_S3_MP --max-threads 96 --part-size 16777216 --allow-other --allow-delete --maximum-throughput-gbps 100 --dir-mode 777
fi


# EFS
if [ ! -z "$EFS_FS_ID" ]; then
  mkdir -p /home/ec2-user/SageMaker/efs
  # sudo mount -t efs -o tls ${EFS_FS_ID}:/ /efs # Using the EFS mount helper
  mkdir -p /home/ec2-user/SageMaker/efs/${EFS_FS_NAME}
  echo "${EFS_FS_ID}.efs.${AWS_REGION}.amazonaws.com:/ /home/ec2-user/SageMaker/efs/${EFS_FS_NAME} efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
  sudo mount -a
  sudo chown -hR +1000:+1000 /home/ec2-user/SageMaker/efs*
  #sudo chmod 777 /home/ec2-user/SageMaker/efs*
fi


echo "==============================================="
echo "  Env, Alias and Path ......"
echo "==============================================="
source ~/.bashrc

# check if a ENV dry exist
if [ -z ${dry} ]; then

  # Add alias if not set before
  cat >> ~/SageMaker/custom/bashrc <<EOF

# Add by sm-nb-MAD
alias ..='source ~/.bashrc'
alias c=clear

alias a=aws
alias aid='aws sts get-caller-identity'

alias z='zip -r ../1.zip .'
alias g=git
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alh --color=auto'
alias ls='ls --color=auto'
alias jc=/bin/journalctl
alias s5='s5cmd'

alias 2s='cd /home/ec2-user/SageMaker'
alias 2c='cd /home/ec2-user/SageMaker/custom'

export TERM=xterm-256color
#export TERM=xterm-color

export dry="--dry-run=client -o yaml"
export KREW_ROOT="\$CUSTOM_DIR/bin/krew"
export PATH="\${KREW_ROOT:-\$HOME/.krew}/bin:\$PATH"

alias nlog=eks-log-collector.sh
alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage" 
alias kk='kubectl-karpenter.sh'
alias kb='k8sgpt'
alias kt=kubetail
alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L karpenter.sh/capacity-type -L node.kubernetes.io/instance-type -L topology.kubernetes.io/zone -L karpenter.sh/nodepool'
alias kgp='kubectl get po -o wide'
alias kga='kubectl get all'
alias kgd='kubectl get deployment -o wide'
alias kgs='kubectl get svc -o wide'
alias ka='kubectl apply -f'
alias ke='kubectl explain'
alias kr='kubectl run \$dry'

alias tk='kt karpenter -n \${KARPENTER_NAMESPACE}'
alias tlbc='kt aws-load-balancer-controller -n kube-system'
alias tebs='kt ebs-csi-controller -n kube-system'
alias tefs='kt efs-csi-controller -n kube-system'

alias egn='eksctl get nodegroup --cluster=\${EKS_CLUSTER_NAME}'
alias ess='eksctl scale nodegroup --cluster=\${EKS_CLUSTER_NAME} --name=system --nodes'
alias esn='eksctl scale nodegroup --cluster=\${EKS_CLUSTER_NAME} -n'
alias es0='eksctl scale nodegroup --cluster=\${EKS_CLUSTER_NAME} --nodes=0 --nodes-min=0 -n'

alias nsel=ec2-instance-selector

alias rr='sudo systemctl daemon-reload; sudo systemctl restart jupyter-server'

# Other

EOF
fi    

source ~/.bashrc

# 检查是否存在别名 'k'
if alias | grep -q '^alias k='; then
  echo "Alias 'k' exists"
else
  echo "Alias 'k' does not exist"
  cat >> ~/SageMaker/custom/bashrc <<EOF
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k

. <(eksctl completion bash)
alias e=eksctl
complete -F __start_eksctl e
EOF
fi

echo " done"