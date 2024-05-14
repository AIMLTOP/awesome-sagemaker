#!/bin/bash
set -eux

sudo -u ec2-user -i <<'EOF'

CUSTOM_DIR=/home/ec2-user/SageMaker/custom
mkdir -p "$CUSTOM_DIR"/bin
echo "export CUSTOM_DIR=${CUSTOM_DIR}" >> ~/SageMaker/custom/bashrc
echo 'export PATH=$PATH:/home/ec2-user/SageMaker/custom/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin' >> ~/SageMaker/custom/bashrc

echo "First Init infra env" # init envs such as vpc, for production please do manually and be careful
wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/infra/env.sh -O /home/ec2-user/SageMaker/custom/env.sh
chmod +x /home/ec2-user/SageMaker/custom/env.sh
/home/ec2-user/SageMaker/custom/env.sh ~/SageMaker/custom/bashrc

EOF

# Under root
echo "Done ..."