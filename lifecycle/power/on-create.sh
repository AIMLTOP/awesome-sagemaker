#!/bin/bash
set -eux

sudo -u ec2-user -i <<'EOF'

CUSTOM_DIR=/home/ec2-user/SageMaker/custom
mkdir -p "$CUSTOM_DIR"/bin

echo "Set helper env and alias"
echo "export CUSTOM_DIR=${CUSTOM_DIR}" >> ~/SageMaker/custom/bashrc
echo 'export PATH=$PATH:/home/ec2-user/SageMaker/custom/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin' >> ~/SageMaker/custom/bashrc

wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/infra/env.sh -O /home/ec2-user/SageMaker/custom/env.sh
chmod +x /home/ec2-user/SageMaker/custom/env.sh
/home/ec2-user/SageMaker/custom/env.sh ~/SageMaker/custom/bashrc

echo "alias ..='source ~/.bashrc'" >> ~/SageMaker/custom/bashrc
echo "alias c=clear" >> ~/SageMaker/custom/bashrc
echo "alias z='zip -r ../1.zip .'" >> ~/SageMaker/custom/bashrc
echo "alias g=git" >> ~/SageMaker/custom/bashrc
echo "alias l='ls -CF'" >> ~/SageMaker/custom/bashrc
echo "alias la='ls -A'" >> ~/SageMaker/custom/bashrc
echo "alias ll='ls -alh --color=auto'" >> ~/SageMaker/custom/bashrc
echo "alias ls='ls --color=auto'" >> ~/SageMaker/custom/bashrc
echo "alias jc=/bin/journalctl" >> ~/SageMaker/custom/bashrc
echo "alias s5='s5cmd' " >> ~/SageMaker/custom/bashrc
echo "alias 2s='cd /home/ec2-user/SageMaker' " >> ~/SageMaker/custom/bashrc
echo "alias 2c='cd /home/ec2-user/SageMaker/custom' " >> ~/SageMaker/custom/bashrc
echo "alias rr='sudo systemctl daemon-reload; sudo systemctl restart jupyter-server' " >> ~/SageMaker/custom/bashrc
echo "export TERM=xterm-256color" >> ~/SageMaker/custom/bashrc
echo "#export TERM=xterm-color" >> ~/SageMaker/custom/bashrc
echo "alias a=aws" >> ~/SageMaker/custom/bashrc
echo "alias aid='aws sts get-caller-identity'" >> ~/SageMaker/custom/bashrc
echo "alias abc='ask-bedrock converse'" >> ~/SageMaker/custom/bashrc
echo "alias nsel=ec2-instance-selector " >> ~/SageMaker/custom/bashrc


echo "Cloning examples and init scripts"
nohup git clone --recurse-submodules https://github.com/TipTopBin/amazon-sagemaker-notebook-instance-customization.git /home/ec2-user/SageMaker/custom/init > /dev/null 2>&1 &
nohup git clone --recurse-submodules https://github.com/TipTopBin/amazon-sagemaker-examples.git /home/ec2-user/SageMaker/examples > /dev/null 2>&1 &

echo "Fetching auto stop script"
wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py -O /home/ec2-user/SageMaker/custom/autostop.py
EOF

# Under root
echo "Done ..."