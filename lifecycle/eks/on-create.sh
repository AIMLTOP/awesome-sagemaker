#!/bin/bash
set -eux

sudo -u ec2-user -i <<'EOF'

echo "Fetching auto stop script"
mkdir -p /home/ec2-user/SageMaker/custom
wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py -O /home/ec2-user/SageMaker/custom/autostop.py
EOF

# Under root
echo "Done ..."