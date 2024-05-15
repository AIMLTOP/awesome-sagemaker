#!/bin/bash
set -eux

# Under ec2-user
sudo -u ec2-user -i <<'EOF'

echo "Init and do your self configuration ..." # Replace with your own bucket and lifecycle name
aws s3 sync s3://$IA_S3_BUCKET/sagemaker/lifecycle/$LC_NAME/ /home/ec2-user/SageMaker/custom/
chmod +x /home/ec2-user/SageMaker/custom/*.sh && chown ec2-user:ec2-user /home/ec2-user/SageMaker/custom/ -R
nohup /home/ec2-user/SageMaker/custom/sm-al2-init.sh > /home/ec2-user/SageMaker/custom/sm-al2-init.log 2>&1 &  # execute asynchronously
nohup /home/ec2-user/SageMaker/custom/sm-al2-jupyter.sh > /home/ec2-user/SageMaker/custom/sm-al2-jupyter.log 2>&1 &
nohup /home/ec2-user/SageMaker/custom/sm-al2-abc.sh > /home/ec2-user/SageMaker/custom/sm-al2-abc.log 2>&1 &

echo "Install Extensions ... "
source /home/ec2-user/anaconda3/bin/activate JupyterSystemEnv
pip install amazon-codewhisperer-jupyterlab-ext
jupyter server extension enable amazon_codewhisperer_jupyterlab_ext
source /home/ec2-user/anaconda3/bin/deactivate

EOF


# Under root
echo "Restarting the Jupyter server.."
sudo systemctl daemon-reload
sudo systemctl restart jupyter-server