#!/bin/bash

# 参考
# https://github.com/fmmasood/eks-cli-init-tools/blob/main/cli_tools.sh
WORKING_DIR=/home/ec2-user/SageMaker/custom
mkdir -p "$WORKING_DIR"


echo "==============================================="
echo "  Config envs ......"
echo "==============================================="
export AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bashrc
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bashrc
aws configure set default.region ${AWS_REGION}
aws configure get default.region
aws configure set region $AWS_REGION
source ~/.bashrc
aws sts get-caller-identity


# 辅助工具
echo "==============================================="
echo "  Install jq, envsubst (from GNU gettext utilities) and bash-completion ......"
echo "==============================================="
# moreutils: The command sponge allows us to read and write to the same file (cat a.txt|sponge a.txt)
sudo amazon-linux-extras install epel -y
sudo yum -y install bash-completion jq gettext moreutils


# 更新 awscli 并配置自动完成
echo "==============================================="
echo "  Upgrade awscli to v2 ......"
echo "==============================================="
sudo mv /bin/aws /bin/aws1
sudo mv ~/anaconda3/bin/aws ~/anaconda3/bin/aws1
ls -l /usr/local/bin/aws
rm -fr awscliv2.zip aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
AWS_COMPLETER=$(which aws_completer)
echo $SHELL
cat >> ~/.bashrc <<EOF
alias a=aws
complete -C '${AWS_COMPLETER}' aws
complete -C '${AWS_COMPLETER}' a
EOF
source ~/.bashrc
aws --version


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
sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o $WORKING_DIR/docker-compose
sudo chmod +x $WORKING_DIR/docker-compose
$WORKING_DIR/docker-compose version


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
sudo tar xzvf /tmp/s5cmd.tar.gz -C /opt/s5cmd
cat >> ~/.bashrc <<EOF
export PATH="/opt/s5cmd:\$PATH"
EOF
source ~/.bashrc
s5cmd version
echo "alias s5='s5cmd'" | tee -a ~/.bashrc
# mv/sync 等注意要加单引号，注意区域配置
# s5cmd mv 's3://xxx-iad/HFDatasets/*' 's3://xxx-iad/datasets/HF/'
# s5 --profile=xxx cp --source-region=us-west-2 s3://xxx.zip ./xxx.zip


# echo "==============================================="
# echo " Persistant Conda ......"
# echo "==============================================="
# # https://docs.conda.io/en/latest/miniconda.html
# # https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/persistent-conda-ebs/on-create.sh
# # installs a custom, persistent installation of conda on the Notebook Instance's EBS volume, and ensures
# # The on-create script downloads and installs a custom conda installation to the EBS volume via Miniconda. Any relevant
# # packages can be installed here.
# #   1. ipykernel is installed to ensure that the custom environment can be used as a Jupyter kernel   
# #   2. Ensure the Notebook Instance has internet connectivity to download the Miniconda installer
# sudo -u ec2-user -i <<'EOF'
# unset SUDO_UID

# # Install a separate conda installation via Miniconda
# WORKING_DIR=/home/ec2-user/SageMaker/custom
# mkdir -p "$WORKING_DIR"
# # wget https://repo.anaconda.com/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh -O "$WORKING_DIR/miniconda.sh"
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$WORKING_DIR/miniconda.sh"
# bash "$WORKING_DIR/miniconda.sh" -b -u -p "$WORKING_DIR/miniconda" 
# rm -rf "$WORKING_DIR/miniconda.sh"
# EOF
# echo "Download custom kernel scripts"
# wget https://raw.githubusercontent.com/AIMLTOP/awesome-sagemaker/main/lifecycle/kernelPython3.10.sh -O /home/ec2-user/SageMaker/custom/kernelPython3.10.sh
# wget https://raw.githubusercontent.com/AIMLTOP/awesome-sagemaker/main/lifecycle/kernelPython3.9.sh -O /home/ec2-user/SageMaker/custom/kernelPython3.9.sh
# wget https://raw.githubusercontent.com/AIMLTOP/awesome-sagemaker/main/lifecycle/kernelPython3.8.sh -O /home/ec2-user/SageMaker/custom/kernelPython3.8.sh


echo "==============================================="
echo "  Stable Diffusion ......"
echo "==============================================="
## AWS Extension
# https://github.com/awslabs/stable-diffusion-aws-extension/blob/main/docs/Environment-Preconfiguration.md
#wget https://raw.githubusercontent.com/TipTopBin/stable-diffusion-aws-extension/main/install.sh -O /home/ec2-user/SageMaker/custom/install-sd.sh
#sh /home/ec2-user/SageMaker/custom/install-sd.sh
#~/environment/aiml/stable-diffusion-webui/webui.sh --enable-insecure-extension-access --skip-torch-cuda-test --no-half --listen
# ~/environment/aiml/stable-diffusion-webui/webui.sh --enable-insecure-extension-access --skip-torch-cuda-test --port 8080 --no-half --listen
## Docker
# https://github.com/TipTopBin/stable-diffusion-webui-docker.git


echo "==============================================="
echo "  Env, Alias and Path ......"
echo "==============================================="
# Tag to Env
# https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/set-env-variable/on-start.sh
echo 'export PATH=$PATH:/home/ec2-user/SageMaker/custom:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin' >> ~/.bashrc
sudo bash -c "cat << EOF > /usr/local/bin/b
#!/bin/bash
/bin/bash
EOF"
sudo chmod +x /usr/local/bin/b
# echo "alias b='/bin/bash'" | tee -a ~/.bashrc
echo 'export WORKING_DIR=/home/ec2-user/SageMaker/custom' >> ~/.bashrc
echo "alias s5='s5cmd'" | tee -a ~/.bashrc
echo "alias c='clear'" | tee -a ~/.bashrc
echo "alias 2s='cd /home/ec2-user/SageMaker'" | tee -a ~/.bashrc
echo "alias 2c='cd /home/ec2-user/SageMaker/custom'" | tee -a ~/.bashrc
echo "alias sa='source activate'" | tee -a ~/.bashrc
echo "alias sd='source deactivate'" | tee -a ~/.bashrc
# echo "alias sd='conda deactivate'" | tee -a ~/.bashrc
echo "alias saj='source activate JupyterSystemEnv'" | tee -a ~/.bashrc
echo "alias ca='conda activate'" | tee -a ~/.bashrc
echo "alias cls='conda env list'" | tee -a ~/.bashrc
echo "alias caj='conda activate JupyterSystemEnv'" | tee -a ~/.bashrc
echo "alias rr='sudo systemctl daemon-reload; sudo systemctl restart jupyter-server'" | tee -a ~/.bashrc
