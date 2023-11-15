#!/bin/bash
set -eux

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -qq awscliv2.zip
sudo ./aws/install --update
rm -rf aws
rm awscliv2.zip
rm -f /home/ec2-user/anaconda3/envs/JupyterSystemEnv/bin/aws


# Under ec2-user
sudo -u ec2-user -i <<'EOF'

echo "Donwload and init ..."
wget https://raw.githubusercontent.com/TipTopBin/awesome-sagemaker/main/lifecycle/init.sh -O /home/ec2-user/SageMaker/custom/init.sh

chmod +x /home/ec2-user/SageMaker/custom/*.sh
chown ec2-user:ec2-user /home/ec2-user/SageMaker/custom/ -R

# bash /home/ec2-user/SageMaker/custom/initNotebook.sh &
nohup /home/ec2-user/SageMaker/custom/initNotebook.sh > /home/ec2-user/SageMaker/custom/initNotebook.log 2>&1 & # execute asynchronously

mkdir -p ~/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/
cat > ~/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/notification.jupyterlab-settings <<EoL
{
    // Notifications
    // @jupyterlab/apputils-extension:notification
    // Notifications settings.
    // *******************************************

    // Fetch official Jupyter news
    // Whether to fetch news from Jupyter news feed. If `true`, it will make a request to a website.
    "fetchNews": "false"
}
EoL

cat > ~/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings <<EoL
{
    // Theme
    // @jupyterlab/apputils-extension:themes
    // Theme manager settings.
    // *************************************

    // Selected Theme
    // Application-level visual styling theme
    "theme": "JupyterLab Dark"
}
EoL

echo "Install Extensions ... "
source /home/ec2-user/anaconda3/bin/activate JupyterSystemEnv

jupyter labextension install jupyterlab-s3-browser
python -m pip install widgetsnbextension
jupyter serverextension enable --py widgetsnbextension

pip install ipywidgets
jupyter nbextension enable widgetsnbextension --py --sys-prefix

pip install amazon-codewhisperer-jupyterlab-ext
jupyter server extension enable amazon_codewhisperer_jupyterlab_ext

source /home/ec2-user/anaconda3/bin/deactivate
EOF


# Under root
echo "Auto stop to save cost ..."
IDLE_TIME=19000
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