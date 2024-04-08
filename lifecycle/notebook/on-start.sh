#!/bin/bash
set -eux

# Under ec2-user
sudo -u ec2-user -i <<'EOF'

echo "Pull code and init ..."
cd /home/ec2-user/SageMaker/custom/init && git pull
chown ec2-user:ec2-user /home/ec2-user/SageMaker/custom/ -R
nohup /home/ec2-user/SageMaker/custom/init/initsmnb/r_init.sh > /home/ec2-user/SageMaker/custom/init.log 2>&1 & # execute asynchronously

echo "Do your self configuration ..."
wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/utils/sm-al2-DIY.sh -O /home/ec2-user/SageMaker/custom/sm-al2-DIY.sh
chmod +x /home/ec2-user/SageMaker/custom/sm-al2-DIY.sh
nohup /home/ec2-user/SageMaker/custom/sm-al2-DIY.sh > /home/ec2-user/SageMaker/custom/sm-al2-DIY.log 2>&1 &

echo "Modern application development ..."
wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/utils/sm-al2-MAD.sh -O /home/ec2-user/SageMaker/custom/sm-al2-MAD.sh
chmod +x /home/ec2-user/SageMaker/custom/sm-al2-MAD.sh
nohup /home/ec2-user/SageMaker/custom/sm-al2-MAD.sh > /home/ec2-user/SageMaker/custom/sm-al2-MAD.log 2>&1 &

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

## Restart JupyterLab
sudo systemctl restart jupyter-server
