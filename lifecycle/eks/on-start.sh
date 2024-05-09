#!/bin/bash
set -eux

# Under ec2-user
sudo -u ec2-user -i <<'EOF'

echo "Init and do your self configuration ..." # For production, please use s3 bucket
# aws s3 cp s3://$IA_S3_BUCKET/sagemaker/lifecycle/${LC_NAME}/sm-al2-init.sh /home/ec2-user/SageMaker/custom/sm-al2-init.sh
# aws s3 cp s3://$IA_S3_BUCKET/sagemaker/lifecycle/${LC_NAME}/sm-al2-jupyter.sh /home/ec2-user/SageMaker/custom/sm-al2-jupyter.sh
# aws s3 cp s3://$IA_S3_BUCKET/sagemaker/lifecycle/${LC_NAME}/autostop.py /home/ec2-user/SageMaker/custom/autostop.py
wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/utils/sm-al2-init.sh -O /home/ec2-user/SageMaker/custom/sm-al2-init.sh
wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/utils/sm-al2-jupyter.sh -O /home/ec2-user/SageMaker/custom/sm-al2-jupyter.sh
wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/utils/sm-al2-abc.sh -O /home/ec2-user/SageMaker/custom/sm-al2-abc.sh
wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py -O /home/ec2-user/SageMaker/custom/autostop.py

chmod +x /home/ec2-user/SageMaker/custom/*.sh
chown ec2-user:ec2-user /home/ec2-user/SageMaker/custom/ -R
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
echo "Auto stop to save cost ..."
IDLE_TIME=18720 # 5.2 hour
# IDLE_TIME=28800 # 8 hour

CONDA_PYTHON_DIR=$(source /home/ec2-user/anaconda3/bin/activate /home/ec2-user/anaconda3/envs/JupyterSystemEnv && which python)
if $CONDA_PYTHON_DIR -c "import boto3" 2>/dev/null; then
    PYTHON_DIR=$CONDA_PYTHON_DIR
elif /usr/bin/python -c "import boto3" 2>/dev/null; then
    PYTHON_DIR='/usr/bin/python'
else
    # If no boto3 just quit because the script won't work
    echo "No boto3 found in Python or Python3. Exiting..."
    exit 1
fi
echo "Found boto3 at $PYTHON_DIR"
echo "Starting the SageMaker autostop script in cron"
(crontab -l 2>/dev/null; echo "*/5 * * * * $PYTHON_DIR /home/ec2-user/SageMaker/custom/autostop.py --time $IDLE_TIME --ignore-connections >> /var/log/jupyter.log") | crontab -


echo "Restarting the Jupyter server.."
sudo systemctl daemon-reload
sudo systemctl restart jupyter-server