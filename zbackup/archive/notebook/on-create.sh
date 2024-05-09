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

echo "Cloning examples and init scripts"
nohup git clone --recurse-submodules https://github.com/TipTopBin/amazon-sagemaker-notebook-instance-customization.git /home/ec2-user/SageMaker/custom/init > /dev/null 2>&1 &
nohup git clone --recurse-submodules https://github.com/TipTopBin/amazon-sagemaker-examples.git /home/ec2-user/SageMaker/examples > /dev/null 2>&1 &

echo "Fetching auto stop script"
wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py -O /home/ec2-user/SageMaker/custom/autostop.py
EOF

# Under root
echo "Done ..."