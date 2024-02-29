#!/bin/bash
set -eux

sudo -u ec2-user -i <<'EOF'

CUSTOM_DIR=/home/ec2-user/SageMaker/custom
mkdir -p "$CUSTOM_DIR"/bin

echo "Set helper env"
export AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
echo "export CUSTOM_DIR=${CUSTOM_DIR}" >> ~/SageMaker/custom/bashrc
echo "export ACCOUNT_ID=${ACCOUNT_ID}" >> ~/SageMaker/custom/bashrc
echo "export AWS_REGION=${AWS_REGION}" >> ~/SageMaker/custom/bashrc

echo "Cloning examples and init scripts"
nohup git clone --recurse-submodules https://github.com/TipTopBin/amazon-sagemaker-notebook-instance-customization.git /home/ec2-user/SageMaker/custom/init > /dev/null 2>&1 &
nohup git clone --recurse-submodules https://github.com/TipTopBin/amazon-sagemaker-examples.git /home/ec2-user/SageMaker/examples > /dev/null 2>&1 &

echo "Fetching auto stop script"
wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py -O /home/ec2-user/SageMaker/custom/autostop.py
EOF

# Under root
echo "Done ..."