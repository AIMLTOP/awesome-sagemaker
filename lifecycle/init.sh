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
echo "  Install utilities ......"
echo "==============================================="
# moreutils: The command sponge allows us to read and write to the same file (cat a.txt|sponge a.txt)
sudo amazon-linux-extras install epel -y
sudo yum groupinstall "Development Tools" -y
sudo yum -y install jq gettext bash-completion moreutils openssl tree zsh xsel xclip amazon-efs-utils nc telnet mtr traceroute netcat 
# sudo yum -y install siege fio ioping dos2unix

if [ ! -f $WORKING_DIR/bin/yq ]; then
  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O $WORKING_DIR/bin/yq
  chmod +x $WORKING_DIR/bin/yq
fi


echo "==============================================="
echo "  AWS Tools ......"
echo "==============================================="
# Upgrade awscli to v2
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

# Install session-manager
if [ ! -f $WORKING_DIR/bin/session-manager-plugin.rpm ]; then
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "$WORKING_DIR/bin/session-manager-plugin.rpm"
fi
sudo yum install -y $WORKING_DIR/bin/session-manager-plugin.rpm
session-manager-plugin


echo "==============================================="
echo "  Install Python tools e.g. netron ......"
echo "==============================================="
#https://github.com/lutzroeder/netron
pip install netron
# pip install cleanipynb # cleanipynb xxx.ipynb # 注意会把所有的图片附件都清掉
netron --version
# netron [FILE] or netron.start('[FILE]').
python3 -m pip install awscurl
pip3 install httpie


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

if [ ! -f $WORKING_DIR/bin/powerEBS.sh ]; then
  wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/utils/powerEBS.sh -O $WORKING_DIR/bin/powerEBS.sh
  chmod +x $WORKING_DIR/bin/powerEBS.sh
  df -ah
fi


echo "==============================================="
echo "  Container related ......"
echo "==============================================="
ARCH=amd64 # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
PLATFORM=$(uname -s)_$ARCH
if [ ! -f $WORKING_DIR/bin/eksctl_$PLATFORM.tar.gz ]; then
  curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" -o $WORKING_DIR/bin/eksctl_$PLATFORM.tar.gz
  tar -xzf $WORKING_DIR/bin/eksctl_$PLATFORM.tar.gz -C $WORKING_DIR/bin
fi
if [ ! -f $WORKING_DIR/bin/eksctl_150.tar.gz ]; then
  curl -sL "https://github.com/eksctl-io/eksctl/releases/download/v0.150.0/eksctl_Linux_amd64.tar.gz" -o $WORKING_DIR/bin/eksctl_150.tar.gz
  tar -xzf $WORKING_DIR/bin/eksctl_150.tar.gz
  mv eksctl $WORKING_DIR/bin/eksctl150
fi

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

if [ ! -f $WORKING_DIR/bin/kustomize ]; then
  curl -s https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash
  sudo mv -v kustomize $WORKING_DIR/bin
fi
kustomize version

if [ ! -f $WORKING_DIR/bin/kubie ]; then
  wget https://github.com/sbstp/kubie/releases/latest/download/kubie-linux-amd64 -O $WORKING_DIR/bin/kubie
  chmod +x $WORKING_DIR/bin/kubie
fi

# Docker Compose
#sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo mkdir -p /usr/local/lib/docker/cli-plugins/
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
# sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o $WORKING_DIR/docker-compose
# sudo chmod +x $WORKING_DIR/docker-compose
# $WORKING_DIR/docker-compose version


echo "==============================================="
echo "  EC2 tools e.g. ec2-instance-selector ......"
echo "==============================================="
if [ ! -f $WORKING_DIR/bin/ec2-instance-selector ]; then
  curl -Lo $WORKING_DIR/bin/ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.4.1/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 
  chmod +x $WORKING_DIR/bin/ec2-instance-selector
fi

# run this script on your eks node
if [ ! -f $WORKING_DIR/bin/eks-log-collector.sh ]; then
  curl -o $WORKING_DIR/bin/eks-log-collector.sh https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/log-collector-script/linux/eks-log-collector.sh 
  chmod +x $WORKING_DIR/bin/eks-log-collector.sh
fi

# AMI
# export ACCELERATED_AMI=$(aws ssm get-parameter \
#     --name /aws/service/eks/optimized-ami/$EKS_VERSION/amazon-linux-2-gpu/recommended/image_id \
#     --region $AWS_REGION \
#     --query "Parameter.Value" \
#     --output text)


echo "==============================================="
echo " AI/ML ......"
echo "==============================================="
# Ask bedrock
pip install ask-bedrock
echo "alias abc='ask-bedrock converse'" | tee -a ~/.bashrc

# k8sgpt
if [ ! -f $WORKING_DIR/bin/k8sgpt_Linux_x86_64.tar.gz ]; then
  wget -O $WORKING_DIR/bin/k8sgpt_Linux_x86_64.tar.gz https://github.com/k8sgpt-ai/k8sgpt/releases/download/v0.3.25/k8sgpt_Linux_x86_64.tar.gz
  tar -xvf $WORKING_DIR/bin/k8sgpt_Linux_x86_64.tar.gz -C $WORKING_DIR/bin
fi
k8sgpt auth add --backend amazonbedrock --model anthropic.claude-v2
k8sgpt auth list
k8sgpt auth default -p amazonbedrock


echo "==============================================="
echo "  Dev Platform ......"
echo "==============================================="
if [ ! -f $WORKING_DIR/bin/devpod ]; then
  curl -L -o $WORKING_DIR/bin/devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64" 
  # sudo install -c -m 0755 $WORKING_DIR/bin/devpod $WORKING_DIR/bin
  chmod 0755 $WORKING_DIR/bin/devpod
fi


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
alias aid='aws sts get-caller-identity'
complete -C '${AWS_COMPLETER}' aws
complete -C '${AWS_COMPLETER}' a
export WORKING_DIR=/home/ec2-user/SageMaker/custom
alias s5='s5cmd'
alias 2s='cd /home/ec2-user/SageMaker'
alias 2c='cd /home/ec2-user/SageMaker/custom'
alias rr='sudo systemctl daemon-reload; sudo systemctl restart jupyter-server'

alias nsel=ec2-instance-selector
alias nlog=eks-log-collector.sh

alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage" 

source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
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
export dry="--dry-run=client -o yaml"
alias kr='kubectl run \$dry'
alias tk='kt karpenter -n \${KARPENTER_NAMESPACE}'
alias tlbc='kt aws-load-balancer-controller -n kube-system'
alias tebs='kt ebs-csi-controller -n kube-system'
alias tefs='kt efs-csi-controller -n kube-system'

. <(eksctl completion bash)
alias e=eksctl
complete -F __start_eksctl e
alias egn='eksctl get nodegroup --cluster=\${EKS_CLUSTER_NAME}'
alias ess='eksctl scale nodegroup --cluster=\${EKS_CLUSTER_NAME} --name=system --nodes'
alias esn='eksctl scale nodegroup --cluster=\${EKS_CLUSTER_NAME} -n'
alias es0='eksctl scale nodegroup --cluster=\${EKS_CLUSTER_NAME} --nodes=0 --nodes-min=0 -n'

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

# if [ -f /home/ec2-user/SageMaker/custom/id_rsa_${EKS_CLUSTER_NAME} ]
# then
#   sudo cp /home/ec2-user/SageMaker/custom/id_rsa_${EKS_CLUSTER_NAME} ~/.ssh/id_rsa
#   chmod 400 ~/.ssh/id_rsa
#   cp /home/ec2-user/SageMaker/custom/id_rsa_pub_${EKS_CLUSTER_NAME} ~/.ssh/id_rsa.pub
#   # ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub
# fi

if [ -f /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_private_key.pem ]
then
  sudo cp /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_private_key.pem ~/.ssh/id_rsa
  sudo cp /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_public_key.pem ~/.ssh/id_rsa.pub
  sudo chmod 400 ~/.ssh/id_rsa
  sudo chown -R ec2-user:ec2-user ~/.ssh/
  # ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub
fi

if [ -f $WORKING_DIR/profile_bedrock_config ]; then
  # cat $WORKING_DIR/profile_bedrock_config >> ~/.aws/config
  # cat $WORKING_DIR/profile_bedrock_credentials >> ~/.aws/credentials
  cp $WORKING_DIR/profile_bedrock_config ~/.aws/config
  cp $WORKING_DIR/profile_bedrock_credentials ~/.aws/credentials  
fi

if [ -f $WORKING_DIR/abc_config ]; then
  mkdir -p /home/ec2-user/.config/ask-bedrock
  cp $WORKING_DIR/abc_config $HOME/.config/ask-bedrock/config.yaml
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
    # aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}
    /usr/local/bin/aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}
fi


echo "==============================================="
echo "  S3 Bucket ......"
echo "==============================================="
if [ ! -f $WORKING_DIR/bin/mount-s3.rpm ]; then
  wget -O $WORKING_DIR/bin/mount-s3.rpm https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm
fi
sudo yum install -y $WORKING_DIR/bin/mount-s3.rpm
echo "alias ms3='mount-s3'" | tee -a ~/.bashrc
# mount-s3 [OPTIONS] <BUCKET_NAME> <DIRECTORY>
if [ ! -z "$IA_S3_BUCKET" ]; then
    mkdir -p /home/ec2-user/SageMaker/s3/${IA_S3_BUCKET}
    mount-s3 ${IA_S3_BUCKET} /home/ec2-user/SageMaker/s3/${IA_S3_BUCKET}
fi



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


echo "==============================================="
echo "  Local Stable Diffusion ......"
echo "==============================================="
if [ ! -z "$SD_HOME" ]; then
  cd $SD_HOME/sd-webui # WorkingDirectory 注意一定要进入到这个目录
  # TODO check GPU
  nohup $SD_HOME/sd-webui/webui.sh --gradio-auth admin:${SD_PWD} --cors-allow-origins=* --enable-insecure-extension-access --allow-code --medvram --xformers --listen --port 8760 > $SD_HOME/sd.log 2>&1 & # execute asynchronously
fi


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