#!/bin/bash

source ~/.bashrc

CUSTOM_DIR=/home/ec2-user/SageMaker/custom
mkdir -p "$CUSTOM_DIR"/bin

echo "==============================================="
echo "  Resource Metadata ......"
echo "==============================================="
if [ -z ${SAGE_NB_NAME} ]; then
  # Add SageMaker related ENVs if not set before
#   cat >> ~/SageMaker/custom/bashrc <<EOF

# # Add by sm-nb-DIY
# alias abc='ask-bedrock converse'

# EOF

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


echo "==============================================="
echo "  Storage  ......"
echo "==============================================="
# S3 bucket
# mount-s3 [OPTIONS] <BUCKET_NAME> <DIRECTORY>
if [ ! -z "$IA_S3_BUCKET" ]; then
    mkdir -p /home/ec2-user/SageMaker/s3/${IA_S3_BUCKET}
    mount-s3 ${IA_S3_BUCKET} /home/ec2-user/SageMaker/s3/${IA_S3_BUCKET}
fi


# EFS
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
echo "  Development ......"
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
  sudo tar xzvf flink-*.tgz -C $CUSTOM_DIR/
  sudo chown -R ec2-user $CUSTOM_DIR/flink-1.16.3
  # flink -v
  cat >> ~/SageMaker/custom/bashrc <<EOF
export PATH="$CUSTOM_DIR/flink-1.16.3/bin:\$PATH"
EOF

fi


echo "==============================================="
echo "  AI/ML ......"
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
# https://github.com/awslabs/mlspace
# https://mlspace.readthedocs.io/en/latest/index.html

# aws configure --profile bedrock
# ask-bedrock converse
# ask-bedrock configure


echo "  Local Stable Diffusion ......"
if [ ! -z "$SD_HOME" ]; then
  cd $SD_HOME/sd-webui # WorkingDirectory 注意一定要进入到这个目录
  # TODO check GPU
  nohup $SD_HOME/sd-webui/webui.sh --gradio-auth admin:${SD_PWD} --cors-allow-origins=* --enable-insecure-extension-access --allow-code --medvram --xformers --listen --port 8760 > $SD_HOME/sd.log 2>&1 & # execute asynchronously
fi