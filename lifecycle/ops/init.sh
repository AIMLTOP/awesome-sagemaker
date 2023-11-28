#!/bin/bash

WORKING_DIR=/home/ec2-user/SageMaker/custom
mkdir -p "$WORKING_DIR"/bin


echo "==============================================="
echo "  Config envs ......"
echo "==============================================="
export AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bashrc
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bashrc
aws configure set default.region ${AWS_REGION}
aws configure get default.region
aws configure set region $AWS_REGION


# 辅助工具
echo "==============================================="
echo "  Install jq, envsubst (from GNU gettext utilities) and bash-completion ......"
echo "==============================================="
# moreutils: The command sponge allows us to read and write to the same file (cat a.txt|sponge a.txt)
sudo amazon-linux-extras install epel -y
sudo yum -y install jq gettext bash-completion moreutils openssl tree zsh xsel xclip amazon-efs-utils


echo "==============================================="
echo "  Upgrade awscli to v2 ......"
echo "==============================================="
if [ ! -f $WORKING_DIR/bin/awscliv2.zip ]; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$WORKING_DIR/bin/awscliv2.zip"
  # unzip -qq awscliv2.zip -C
  unzip -o $WORKING_DIR/bin/awscliv2.zip -d $WORKING_DIR/bin
fi
sudo $WORKING_DIR/bin/aws/install --update
rm -f /home/ec2-user/anaconda3/envs/JupyterSystemEnv/bin/aws
sudo mv ~/anaconda3/bin/aws ~/anaconda3/bin/aws1
ls -l /usr/local/bin/aws
source ~/.bashrc
aws --version


echo "==============================================="
echo "  Install session-manager ......"
echo "==============================================="
if [ ! -f $WORKING_DIR/bin/session-manager-plugin.rpm ]; then
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "$WORKING_DIR/bin/session-manager-plugin.rpm"
fi
sudo yum install -y $WORKING_DIR/bin/session-manager-plugin.rpm
session-manager-plugin


echo "==============================================="
echo "  Docker Compose ......"
echo "==============================================="
#sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo mkdir -p /usr/local/lib/docker/cli-plugins/
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
# sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o $WORKING_DIR/docker-compose
# sudo chmod +x $WORKING_DIR/docker-compose
# $WORKING_DIR/docker-compose version


echo "==============================================="
echo "  Install netron ......"
echo "==============================================="
#https://github.com/lutzroeder/netron
pip install netron
netron --version
# netron [FILE] or netron.start('[FILE]').


echo "==============================================="
echo " s5cmd ......"
echo "==============================================="
#https://github.com/peak/s5cmd
if [ ! -f $WORKING_DIR/bin/s5cmd ]; then
    echo "Setup s5cmd"
    export S5CMD_URL=$(curl -s https://api.github.com/repos/peak/s5cmd/releases/latest \
    | grep "browser_download_url.*_Linux-64bit.tar.gz" \
    | cut -d : -f 2,3 \
    | tr -d \")
    # echo $S5CMD_URL
    wget $S5CMD_URL -O /tmp/s5cmd.tar.gz
    sudo mkdir -p /opt/s5cmd/
    sudo tar xzvf /tmp/s5cmd.tar.gz -C $WORKING_DIR/bin
fi
# mv/sync 等注意要加单引号，注意区域配置
# s5cmd mv 's3://xxx-iad/HFDatasets/*' 's3://xxx-iad/datasets/HF/'
# s5 --profile=xxx cp --source-region=us-west-2 s3://xxx.zip ./xxx.zip


echo "==============================================="
echo "  Optimize Disk Space ......"
echo "==============================================="
# https://docs.aws.amazon.com/sagemaker/latest/dg/docker-containers-troubleshooting.html
mkdir -p ~/.sagemaker
cat > ~/.sagemaker/config.yaml <<EOF
local:
  container_root: /home/ec2-user/SageMaker/tmp
EOF


echo "==============================================="
echo "  Container related ......"
echo "==============================================="
ARCH=amd64 # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
PLATFORM=$(uname -s)_$ARCH
if [ ! -f $WORKING_DIR/bin/eksctl_$PLATFORM.tar.gz ]; then
  curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" -o $WORKING_DIR/bin/eksctl_$PLATFORM.tar.gz
  tar -xzf $WORKING_DIR/bin/eksctl_$PLATFORM.tar.gz -C $WORKING_DIR/bin
fi
eksctl version

if [ ! -f $WORKING_DIR/bin/kubectl ]; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  mv kubectl /tmp/
  sudo install -o root -g root -m 0755 /tmp/kubectl $WORKING_DIR/bin/kubectl
fi

if [ ! -f $WORKING_DIR/bin/get_helm.sh ]; then
  curl -fsSL -o $WORKING_DIR/bin/get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod 700 $WORKING_DIR/bin/get_helm.sh
fi
$WORKING_DIR/bin/get_helm.sh
helm version
helm repo add eks https://aws.github.io/eks-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update
# docker logout public.ecr.aws
helm registry logout public.ecr.aws

if [ ! -f $WORKING_DIR/bin/kubectl-karpenter.sh ]; then
  curl -fsSL -o $WORKING_DIR/bin/kubectl-karpenter.sh https://raw.githubusercontent.com/TipTopBin/aws-do-eks/main/utils/kubectl-karpenter.sh
  chmod +x $WORKING_DIR/bin/kubectl-karpenter.sh
fi

curl -sS https://webinstall.dev/k9s | bash

if [ ! -f $WORKING_DIR/bin/kubetail ]; then
  curl -o $WORKING_DIR/bin/kubetail https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
  chmod +x $WORKING_DIR/bin/kubetail
fi


echo "==============================================="
echo " Ask bedrock ......"
echo "==============================================="
pip install ask-bedrock
echo "alias abc='ask-bedrock converse'" | tee -a ~/.bashrc
# aws configure --profile bedrock
# ask-bedrock converse
# ask-bedrock configure


echo "==============================================="
echo " k8sgpt ......"
echo "==============================================="
curl -LO https://github.com/k8sgpt-ai/k8sgpt/releases/download/v0.3.21/k8sgpt_amd64.deb
sudo dpkg -i k8sgpt_amd64.deb
echo "alias kb='k8sgpt'" | tee -a ~/.bashrc
# k8sgpt auth add --backend amazonbedrock --model anthropic.claude-v2
# k8sgpt auth list
# k8sgpt auth default -p amazonbedrock
# k8sgpt analyze -e -b amazonbedrock
# export AWS_ACCESS_KEY=
# export AWS_SECRET_ACCESS_KEY=
# export AWS_DEFAULT_REGION=


echo "==============================================="
echo "  Env, Alias and Path ......"
echo "==============================================="
wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/infra/env.sh -O /home/ec2-user/SageMaker/custom/env.sh
chmod +x /home/ec2-user/SageMaker/custom/env.sh
/home/ec2-user/SageMaker/custom/env.sh

# Tag to Env
# https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/set-env-variable/on-start.sh
echo 'export PATH=$PATH:/home/ec2-user/SageMaker/custom/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin' >> ~/.bashrc
sudo bash -c "cat << EOF > /usr/local/bin/b
#!/bin/bash
/bin/bash
EOF"
sudo chmod +x /usr/local/bin/b
AWS_COMPLETER=$(which aws_completer)
echo $SHELL
cat >> ~/.bashrc <<EOF
alias ..='source ~/.bashrc'
alias c=clear
alias z='zip -r ../1.zip .'
alias g=git
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alh --color=auto'
alias ls='ls --color=auto'
alias jc=/bin/journalctl
# alias gpa='git pull-all'
alias gpa='git pull-all && git submodule update --remote'
alias gca='git clone-all'
export TERM=xterm-256color
#export TERM=xterm-color
alias a=aws
complete -C '${AWS_COMPLETER}' aws
complete -C '${AWS_COMPLETER}' a
export WORKING_DIR=/home/ec2-user/SageMaker/custom
alias s5='s5cmd'
alias 2s='cd /home/ec2-user/SageMaker'
alias 2c='cd /home/ec2-user/SageMaker/custom'
alias rr='sudo systemctl daemon-reload; sudo systemctl restart jupyter-server'

source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
alias kk='kubectl-karpenter.sh'
alias kt=kubetail
alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L karpenter.sh/capacity-type -L node.kubernetes.io/instance-type -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name'
alias kgp='kubectl get po -o wide'
alias kga='kubectl get all'
alias kgd='kubectl get deployment -o wide'
alias kgs='kubectl get svc -o wide'
alias ka='kubectl apply -f'
alias ke='kubectl explain'
export dry="--dry-run=client -o yaml"
alias kr='kubectl run \$dry'
alias tk='kt karpenter -n karpenter'
alias tlbc='kt aws-load-balancer-controller -n kube-system'
alias tebs='kt ebs-csi-controller -n kube-system'
alias tefs='kt efs-csi-controller -n kube-system'

. <(eksctl completion bash)
alias e=eksctl
complete -F __start_eksctl e
alias egn='eksctl get nodegroup --cluster=\${EKS_CLUSTER_NAME}'
alias ess='eksctl scale nodegroup --cluster=\${EKS_CLUSTER_NAME} --name=system --nodes'
alias esn='eksctl scale nodegroup --cluster=\${EKS_CLUSTER_NAME} --name'

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

# if [ -f /home/ec2-user/SageMaker/custom/bashrc ]
# then
#   cat /home/ec2-user/SageMaker/custom/bashrc >> ~/.bashrc
# fi


source ~/.bashrc

if [ -f /home/ec2-user/SageMaker/custom/id_rsa_${EKS_CLUSTER_NAME} ]
then
  sudo cp /home/ec2-user/SageMaker/custom/id_rsa_${EKS_CLUSTER_NAME} ~/.ssh/id_rsa
  chmod 400 ~/.ssh/id_rsa
  cp /home/ec2-user/SageMaker/custom/id_rsa_pub_${EKS_CLUSTER_NAME} ~/.ssh/id_rsa.pub
  # ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub
fi

echo "==============================================="
echo "  Resource Metadata ......"
echo "==============================================="
export SAGE_NB_NAME=$(cat /opt/ml/metadata/resource-metadata.json | jq .ResourceName | tr -d '"')
export SAGE_LC_NAME=$(aws sagemaker describe-notebook-instance --notebook-instance-name ${SAGE_NB_NAME} --query NotebookInstanceLifecycleConfigName --output text)
export SAGE_ROLE_ARN=$(aws sagemaker describe-notebook-instance --notebook-instance-name ${SAGE_NB_NAME} --query RoleArn --output text)
export SAGE_ROLE_NAME=$(echo ${SAGE_ROLE_ARN##*/})

echo "export SAGE_NB_NAME=\"$SAGE_NB_NAME\"" >> ~/.bashrc
echo "export SAGE_LC_NAME=\"$SAGE_LC_NAME\"" >> ~/.bashrc
echo "export SAGE_ROLE_NAME=\"$SAGE_ROLE_NAME\"" >> ~/.bashrc
echo "export SAGE_ROLE_ARN=\"$SAGE_ROLE_ARN\"" >> ~/.bashrc


echo "==============================================="
echo "  EKS Cluster ......"
echo "==============================================="
if [ ! -z "$EKS_CLUSTER_NAME" ]; then
    aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}
fi


echo "==============================================="
echo "  S3 Bucket ......"
echo "==============================================="
export IA_S3_BUCKET=ia-${ACCOUNT_ID}-${AWS_REGION}
# Check if bucket exists 
bucket_exists=$(aws s3api head-bucket --bucket ${IA_S3_BUCKET} --region ${AWS_REGION} 2>/dev/null)
# Create bucket if not exists
if [ $? -ne 0 ]; then
  echo "Bucket ${IA_S3_BUCKET} does not exist, creating..."
  if [ ${AWS_REGION} == 'us-east-1' ]
  then
    aws s3api create-bucket --bucket ${IA_S3_BUCKET} --region ${AWS_REGION}
  else
    aws s3api create-bucket --bucket ${IA_S3_BUCKET} --region ${AWS_REGION} --create-bucket-configuration LocationConstraint=${AWS_REGION}
  fi  
else
  echo "Bucket ${IA_S3_BUCKET} already exists"  
fi

echo "export IA_S3_BUCKET=\"$IA_S3_BUCKET\"" >> ~/.bashrc

if [ ! -f $WORKING_DIR/bin/mount-s3.rpm ]; then
  wget -O $WORKING_DIR/bin/mount-s3.rpm https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm
fi
sudo yum install -y $WORKING_DIR/bin/mount-s3.rpm
echo "alias ms3='mount-s3'" | tee -a ~/.bashrc
# mount-s3 [OPTIONS] <BUCKET_NAME> <DIRECTORY>
mkdir -p /home/ec2-user/SageMaker/s3/${IA_S3_BUCKET}
mount-s3 ${IA_S3_BUCKET} /home/ec2-user/SageMaker/s3/${IA_S3_BUCKET}


echo "==============================================="
echo "  EFS ......"
echo "==============================================="
if [ ! -z "$EFS_FS_ID" ]; then
  mkdir -p /home/ec2-user/SageMaker/efs
  # sudo mount -t efs -o tls ${EFS_FS_ID}:/ /efs # Using the EFS mount helper
  echo "${EFS_FS_ID}.efs.${AWS_REGION}.amazonaws.com:/ /home/ec2-user/SageMaker/efs efs _netdev,tls 0 0" | sudo tee -a /etc/fstab  
fi
sudo mount -a
sudo chown -hR +1000:+1000 /home/ec2-user/SageMaker/efs*
#sudo chmod 777 /home/ec2-user/SageMaker/efs*


##--------------------- Check ENVs -------------------##
source ~/.bashrc

echo -e " EKS_CLUSTER_NAME: $EKS_CLUSTER_NAME\n" \
  "EKS_VERSION: $EKS_VERSION\n" \
  "EKS_MASTER_ARN: ${EKS_MASTER_ARN}\n" \
  "SAGE_NB_NAME: $SAGE_NB_NAME\n" \
  "SAGE_LC_NAME: $SAGE_LC_NAME\n" \
  "SAGE_ROLE_NAME: $SAGE_ROLE_NAME\n" \
  "SAGE_ROLE_ARN: $SAGE_ROLE_ARN\n" \
  "IA_S3_BUCKET: $IA_S3_BUCKET\n" \
  "EFS_FS_NAME: ${EFS_FS_NAME}\n" \
  "EFS_FS_ID: ${EFS_FS_ID}\n" \
  "EFS_PV_DEFAULT: $EFS_PV_DEFAULT\n" \
  "EFS_CLAIM_DEFAULT: $EFS_CLAIM_DEFAULT\n" \
  "EFS_PV_OTEL: $EFS_PV_OTEL\n" \
  "EFS_CLAIM_OTEL: $EFS_CLAIM_OTEL\n" \
  "EMR_VIRTUAL_CLUSTER_NAME: $EMR_VIRTUAL_CLUSTER_NAME\n" \
  "EMR_VIRTUAL_CLUSTER_NS: $EMR_VIRTUAL_CLUSTER_NS\n" \
  "EMR_VIRTUAL_CLUSTER_ID: $EMR_VIRTUAL_CLUSTER_ID\n" \
  "ECR_DATAML_REPO: $ECR_DATAML_REPO\n" \
  "ELB_NLB_ARN: $ELB_NLB_ARN\n"

echo " done"