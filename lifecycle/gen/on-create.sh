#!/bin/bash
set -eux

sudo -u ec2-user -i <<'EOF'

cd ~/SageMaker
mkdir -p /home/ec2-user/SageMaker/custom

echo "Fetching the helper script"
wget https://raw.githubusercontent.com/AIMLTOP/awesome-sagemaker/main/utils/prepareNotebook.sh -O /home/ec2-user/SageMaker/custom/prepareNotebook.sh
wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py -O /home/ec2-user/SageMaker/custom/autostop.py

chmod +x /home/ec2-user/SageMaker/custom/*.sh
chown ec2-user:ec2-user /home/ec2-user/SageMaker/custom/ -R
EOF

echo "Done ..."