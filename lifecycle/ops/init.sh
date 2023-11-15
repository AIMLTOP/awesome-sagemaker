#!/bin/bash

# https://github.com/fmmasood/eks-cli-init-tools/blob/main/cli_tools.sh
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
sudo yum -y install bash-completion jq gettext moreutils


echo "==============================================="
echo "  Install session-manager ......"
echo "==============================================="
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo yum install -y session-manager-plugin.rpm
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
export S5CMD_URL=$(curl -s https://api.github.com/repos/peak/s5cmd/releases/latest \
| grep "browser_download_url.*_Linux-64bit.tar.gz" \
| cut -d : -f 2,3 \
| tr -d \")
# echo $S5CMD_URL
wget $S5CMD_URL -O /tmp/s5cmd.tar.gz
sudo mkdir -p /opt/s5cmd/
sudo tar xzvf /tmp/s5cmd.tar.gz -C $WORKING_DIR/bin
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
echo "  Env, Alias and Path ......"
echo "==============================================="
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
alias c=clear
alias z='zip -r ../1.zip .'
alias g=git
alias ll='ls -alh --color=auto'
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
EOF
# echo "alias b='/bin/bash'" | tee -a ~/.bashrc
echo "" | tee -a ~/.bashrc
source ~/.bashrc