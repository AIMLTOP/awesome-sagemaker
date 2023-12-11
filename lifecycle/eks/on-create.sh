#!/bin/bash
set -eux

sudo -u ec2-user -i <<'EOF'

echo "Fetching auto stop script"
mkdir -p /home/ec2-user/SageMaker/custom
aws s3 cp s3://${IA_S3_BUCKET}/sagemaker/lifecycle/eks/autostop.py /home/ec2-user/SageMaker/custom/autostop.py
EOF

# Under root
echo "Done ..."