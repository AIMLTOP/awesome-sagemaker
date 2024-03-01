#!/bin/bash
set -eux

# Under ec2-user
sudo -u ec2-user -i <<'EOF'

echo "Pull code and init ..."
cd /home/ec2-user/SageMaker/custom/init && git pull
chown ec2-user:ec2-user /home/ec2-user/SageMaker/custom/ -R
nohup /home/ec2-user/SageMaker/custom/init/initsmnb/r_init.sh > /home/ec2-user/SageMaker/custom/init.log 2>&1 & # execute asynchronously

echo "Do your self configuration ..."
wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/utils/sm-nb-DIY.sh -O /home/ec2-user/SageMaker/custom/sm-nb-DIY.sh
chmod +x /home/ec2-user/SageMaker/custom/sm-nb-DIY.sh
nohup /home/ec2-user/SageMaker/custom/sm-nb-DIY.sh > /home/ec2-user/SageMaker/custom/sm-nb-DIY.log 2>&1 &

echo "Add EKS toolset ..."
wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/utils/sm-nb-EKS.sh -O /home/ec2-user/SageMaker/custom/sm-nb-EKS.sh
chmod +x /home/ec2-user/SageMaker/custom/sm-nb-EKS.sh
nohup /home/ec2-user/SageMaker/custom/sm-nb-EKS.sh > /home/ec2-user/SageMaker/custom/sm-nb-EKS.log 2>&1 &
EOF


# Under root
echo "Auto stop to save cost ..."
IDLE_TIME=9720 # 2.7 hour
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
