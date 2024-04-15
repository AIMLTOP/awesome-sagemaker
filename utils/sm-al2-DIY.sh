#!/bin/bash

source ~/.bashrc

CUSTOM_DIR=/home/ec2-user/SageMaker/custom
mkdir -p "$CUSTOM_DIR"/bin

echo "==============================================="
echo "  Resource Metadata ......"
echo "==============================================="
if [ -z ${SAGE_NB_NAME} ]; then
  # Add SageMaker related ENVs if not set before
  cat >> ~/SageMaker/custom/bashrc <<EOF

# Add by sm-nb-DIY
alias ..='source ~/.bashrc'
alias c=clear
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
alias rr='sudo systemctl daemon-reload; sudo systemctl restart jupyter-server'
export TERM=xterm-256color
#export TERM=xterm-color
alias a=aws
alias aid='aws sts get-caller-identity'
alias abc='ask-bedrock converse'
alias nsel=ec2-instance-selector
EOF

  export SAGE_NB_NAME=$(cat /opt/ml/metadata/resource-metadata.json | jq .ResourceName | tr -d '"')
  export SAGE_LC_NAME=$(aws sagemaker describe-notebook-instance --notebook-instance-name ${SAGE_NB_NAME} --query NotebookInstanceLifecycleConfigName --output text)
  export SAGE_ROLE_ARN=$(aws sagemaker describe-notebook-instance --notebook-instance-name ${SAGE_NB_NAME} --query RoleArn --output text)
  # Get sagemaker role ROLENAME 
  export SAGE_ROLE_NAME=$(echo ${SAGE_ROLE_ARN##*/})
  # export SAGE_ROLE_NAME=$(basename "$ROLE") # another way

  echo "export SAGE_NB_NAME=\"$SAGE_NB_NAME\"" >> ~/SageMaker/custom/bashrc
  echo "export SAGE_LC_NAME=\"$SAGE_LC_NAME\"" >>~/SageMaker/custom/bashrc
  echo "export SAGE_ROLE_NAME=\"$SAGE_ROLE_NAME\"" >> ~/SageMaker/custom/bashrc
  echo "export SAGE_ROLE_ARN=\"$SAGE_ROLE_ARN\"" >> ~/SageMaker/custom/bashrc
fi



echo "==============================================="
echo " More tools ......"
echo "==============================================="
# Ask bedrock
pip install ask-bedrock

if [ -f $CUSTOM_DIR/profile_bedrock_config ]; then
  # cat $CUSTOM_DIR/profile_bedrock_config >> ~/.aws/config
  # cat $CUSTOM_DIR/profile_bedrock_credentials >> ~/.aws/credentials
  cp $CUSTOM_DIR/profile_bedrock_config ~/.aws/config
  cp $CUSTOM_DIR/profile_bedrock_credentials ~/.aws/credentials  
fi

if [ -f $CUSTOM_DIR/abc_config ]; then
  mkdir -p /home/ec2-user/.config/ask-bedrock
  cp $CUSTOM_DIR/abc_config $HOME/.config/ask-bedrock/config.yaml
fi


# https://github.com/muesli/duf
echo "Setup duf"
if [ ! -f $CUSTOM_DIR/duf.rpm ]; then
    DOWNLOAD_URL="https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_amd64.rpm"
    wget $DOWNLOAD_URL -O $CUSTOM_DIR/duf.rpm
fi
sudo yum localinstall -y $CUSTOM_DIR/duf.rpm

# moreutils: The command sponge allows us to read and write to the same file (cat a.txt|sponge a.txt)
sudo yum groupinstall "Development Tools" -y
sudo yum -y install jq gettext bash-completion moreutils openssl zsh xsel xclip amazon-efs-utils nc telnet mtr traceroute netcat 
# sudo yum -y install siege fio ioping dos2unix

if [ ! -f $CUSTOM_DIR/bin/yq ]; then
  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O $CUSTOM_DIR/bin/yq
  chmod +x $CUSTOM_DIR/bin/yq
fi

#https://github.com/lutzroeder/netron
pip install netron
# pip install cleanipynb # cleanipynb xxx.ipynb # 注意会把所有的图片附件都清掉
netron --version
# netron [FILE] or netron.start('[FILE]').
python3 -m pip install awscurl
pip3 install httpie


# ec2-instance-selector
if [ ! -f $CUSTOM_DIR/bin/ec2-instance-selector ]; then
  target=$(uname | tr '[:upper:]' '[:lower:]')-amd64
  LATEST_DOWNLOAD_URL=$(curl --silent $CUSTOM_DIR/bin/ec2-instance-selector "https://api.github.com/repos/aws/amazon-ec2-instance-selector/releases/latest" | grep "\"browser_download_url\": \"https.*$target.tar.gz" | sed -E 's/.*"([^"]+)".*/\1/')
  curl -Lo $CUSTOM_DIR/bin/ec2-instance-selector.tar.gz $LATEST_DOWNLOAD_URL
  tar -xvf $CUSTOM_DIR/bin/ec2-instance-selector.tar.gz -C $CUSTOM_DIR/bin
  # curl -Lo $CUSTOM_DIR/bin/ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.4.1/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 
  chmod +x $CUSTOM_DIR/bin/ec2-instance-selector
fi


echo "==============================================="
echo "  Storage  ......"
echo "==============================================="
## S3 Bucket
if [ ! -f $CUSTOM_DIR/bin/mount-s3.rpm ]; then
  wget -O $CUSTOM_DIR/bin/mount-s3.rpm https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm
fi
sudo yum install -y $CUSTOM_DIR/bin/mount-s3.rpm
echo "alias ms3='mount-s3'" | tee -a ~/.bashrc
# mount-s3 [OPTIONS] <BUCKET_NAME> <DIRECTORY>
if [ ! -z "$IA_S3_BUCKET" ]; then
    mkdir -p /home/ec2-user/SageMaker/s3/${IA_S3_BUCKET}
    mount-s3 ${IA_S3_BUCKET} /home/ec2-user/SageMaker/s3/${IA_S3_BUCKET}
fi

## s5cmd
# https://github.com/peak/s5cmd
if [ ! -f $CUSTOM_DIR/bin/s5cmd ]; then
    echo "Setup s5cmd"
    # export S5CMD_URL=$(curl -s https://api.github.com/repos/peak/s5cmd/releases/latest \
    # | grep "browser_download_url.*_Linux-64bit.tar.gz" \
    # | cut -d : -f 2,3 \
    # | tr -d \")
    S5CMD_URL="https://github.com/peak/s5cmd/releases/download/v2.2.2/s5cmd_2.2.2_Linux-64bit.tar.gz"
    wget $S5CMD_URL -O /tmp/s5cmd.tar.gz
    sudo mkdir -p /opt/s5cmd/
    sudo tar xzvf /tmp/s5cmd.tar.gz -C $CUSTOM_DIR/bin
fi

## EFS
if [ ! -z "$EFS_FS_ID" ]; then
  mkdir -p /home/ec2-user/SageMaker/efs
  # sudo mount -t efs -o tls ${EFS_FS_ID}:/ /efs # Using the EFS mount helper
  echo "${EFS_FS_ID}.efs.${AWS_REGION}.amazonaws.com:/ /home/ec2-user/SageMaker/efs efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
  sudo mount -a
  sudo chown -hR +1000:+1000 /home/ec2-user/SageMaker/efs*
  #sudo chmod 777 /home/ec2-user/SageMaker/efs*
fi


## Lustre
## https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/mount-fsx-lustre-file-system/on-start.sh



echo "==============================================="
echo "  Local Stable Diffusion ......"
echo "==============================================="
if [ ! -z "$SD_HOME" ]; then
  cd $SD_HOME/sd-webui # WorkingDirectory 注意一定要进入到这个目录
  # TODO check GPU
  nohup $SD_HOME/sd-webui/webui.sh --gradio-auth admin:${SD_PWD} --cors-allow-origins=* --enable-insecure-extension-access --allow-code --medvram --xformers --listen --port 8760 > $SD_HOME/sd.log 2>&1 & # execute asynchronously
fi


echo "==============================================="
echo "  Dev Tools ......"
echo "==============================================="
if [ ! -f $CUSTOM_DIR/bin/devpod ]; then
  curl -L -o $CUSTOM_DIR/bin/devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64" 
  # sudo install -c -m 0755 $CUSTOM_DIR/bin/devpod $CUSTOM_DIR/bin
  chmod 0755 $CUSTOM_DIR/bin/devpod
fi


if [ ! -f $CUSTOM_DIR/apache-maven-3.8.6/bin/mvn ]; then
  echo "  Install Maven ......"
  wget https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz -O /tmp/apache-maven-3.8.6-bin.tar.gz
  sudo tar xzvf /tmp/apache-maven-3.8.6-bin.tar.gz -C $CUSTOM_DIR
  cat >> ~/SageMaker/custom/bashrc <<EOF
export PATH="$CUSTOM_DIR/apache-maven-3.8.6/bin:\$PATH"
EOF
  # mvn --version  
fi


echo "==============================================="
echo "  Data ......"
echo "==============================================="
if [ ! -f $CUSTOM_DIR/flink-1.16.3/bin/flink ]; then
  echo "Setup Flink"
  wget https://dlcdn.apache.org/flink/flink-1.16.3/flink-1.16.3-bin-scala_2.12.tgz
  sudo tar xzvf flink-*.tgz -C $CUSTOM_DIR/flink-1.16.3
  sudo chown -R ec2-user $CUSTOM_DIR/flink-1.16.3
  # flink -v
  cat >> ~/SageMaker/custom/bashrc <<EOF
export PATH="$CUSTOM_DIR/flink-1.16.3/bin:\$PATH"
EOF

fi


echo "==============================================="
echo "  AI/ML ......"
echo "==============================================="
# https://github.com/awslabs/mlspace
# https://mlspace.readthedocs.io/en/latest/index.html

# aws configure --profile bedrock
# ask-bedrock converse
# ask-bedrock configure

echo "==============================================="
echo "  SSH ......"
echo "==============================================="
# if [ -f /home/ec2-user/SageMaker/custom/id_rsa_${EKS_CLUSTER_NAME} ]
# then
#   sudo cp /home/ec2-user/SageMaker/custom/id_rsa_${EKS_CLUSTER_NAME} ~/.ssh/id_rsa
#   chmod 400 ~/.ssh/id_rsa
#   cp /home/ec2-user/SageMaker/custom/id_rsa_pub_${EKS_CLUSTER_NAME} ~/.ssh/id_rsa.pub
#   # ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub
# fi

if [ -f /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_private_key.pem ]
then
  echo "Setup SSH Keys"
  sudo cp /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_private_key.pem ~/.ssh/id_rsa
  sudo cp /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_public_key.pem ~/.ssh/id_rsa.pub
  sudo chmod 400 ~/.ssh/id_rsa
  sudo chown -R ec2-user:ec2-user ~/.ssh/
  # ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub
fi


# Install session-manager
if [ ! -f $CUSTOM_DIR/bin/session-manager-plugin.rpm ]; then
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "$CUSTOM_DIR/bin/session-manager-plugin.rpm"
fi
# sudo yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
sudo yum install -y $CUSTOM_DIR/bin/session-manager-plugin.rpm
session-manager-plugin --version


# sagemaker-hyperpod ssh
# https://catalog.workshops.aws/sagemaker-hyperpod/en-US/01-cluster/05-ssh
if [ ! -f $CUSTOM_DIR/bin/easy-ssh ]; then
  wget -O $CUSTOM_DIR/bin/easy-ssh https://raw.githubusercontent.com/TipTopBin/awesome-distributed-training/main/1.architectures/5.sagemaker-hyperpod/easy-ssh.sh
  chmod +x $CUSTOM_DIR/bin/easy-ssh
fi
# easy-ssh -h
# easy-ssh -c controller-group cluster-name