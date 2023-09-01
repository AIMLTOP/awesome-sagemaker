#!/bin/bash
set -eux

sudo -u ec2-user -i <<'EOF'

cd ~/SageMaker
nohup git clone --recurse-submodules https://github.com/TipTopBin/awesome-sagemaker.git awesome > /dev/null 2>&1 &
# ps -ef | grep awesome

echo "Fetching the helper script"
mkdir -p /home/ec2-user/SageMaker/custom
wget https://raw.githubusercontent.com/AIMLTOP/awesome-sagemaker/main/lifecycle/initNotebook.sh -O /home/ec2-user/SageMaker/custom/initNotebook.sh
wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py -O /home/ec2-user/SageMaker/custom/autostop.py

chmod +x /home/ec2-user/SageMaker/custom/*.sh
chown ec2-user:ec2-user /home/ec2-user/SageMaker/custom/ -R
EOF

# Under root
echo "Done ..."