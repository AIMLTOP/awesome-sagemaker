#!/bin/bash

source ~/.bashrc

echo "==============================================="
echo "  Resource Metadata ......"
echo "==============================================="
if [ -z ${SAGE_NB_NAME} ]; then
  # Add SageMaker related ENVs if not set before
  cat >> ~/SageMaker/custom/bashrc <<EOF

# Add by sm-nb-DIY
export SAGE_NB_NAME=$(cat /opt/ml/metadata/resource-metadata.json | jq .ResourceName | tr -d '"')
export SAGE_LC_NAME=$(aws sagemaker describe-notebook-instance --notebook-instance-name ${SAGE_NB_NAME} --query NotebookInstanceLifecycleConfigName --output text)
export SAGE_ROLE_ARN=$(aws sagemaker describe-notebook-instance --notebook-instance-name ${SAGE_NB_NAME} --query RoleArn --output text)
export SAGE_ROLE_NAME=$(echo ${SAGE_ROLE_ARN##*/})

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


echo "==============================================="
echo "  S3 Bucket ......"
echo "==============================================="
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


echo "==============================================="
echo "  EFS ......"
echo "==============================================="
if [ ! -z "$EFS_FS_ID" ]; then
  mkdir -p /home/ec2-user/SageMaker/efs
  # sudo mount -t efs -o tls ${EFS_FS_ID}:/ /efs # Using the EFS mount helper
  echo "${EFS_FS_ID}.efs.${AWS_REGION}.amazonaws.com:/ /home/ec2-user/SageMaker/efs efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
  sudo mount -a
  sudo chown -hR +1000:+1000 /home/ec2-user/SageMaker/efs*
  #sudo chmod 777 /home/ec2-user/SageMaker/efs*
fi


echo "==============================================="
echo "  Local Stable Diffusion ......"
echo "==============================================="
if [ ! -z "$SD_HOME" ]; then
  cd $SD_HOME/sd-webui # WorkingDirectory 注意一定要进入到这个目录
  # TODO check GPU
  nohup $SD_HOME/sd-webui/webui.sh --gradio-auth admin:${SD_PWD} --cors-allow-origins=* --enable-insecure-extension-access --allow-code --medvram --xformers --listen --port 8760 > $SD_HOME/sd.log 2>&1 & # execute asynchronously
fi


echo "==============================================="
echo "  Dev Platform ......"
echo "==============================================="
if [ ! -f $CUSTOM_DIR/bin/devpod ]; then
  curl -L -o $CUSTOM_DIR/bin/devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64" 
  # sudo install -c -m 0755 $CUSTOM_DIR/bin/devpod $CUSTOM_DIR/bin
  chmod 0755 $CUSTOM_DIR/bin/devpod
fi
