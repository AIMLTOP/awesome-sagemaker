#!/bin/bash
set -eux

sudo -u ec2-user -i <<'EOF'

bash /home/ec2-user/SageMaker/custom/prepareNotebook.sh & # execute asynchronously

echo "Config Git ..."
git config --global alias.clone-all 'clone --recurse-submodules'
git config --global alias.pull-all 'pull --recurse-submodules'

echo "Install Extensions ... "
LAB_EXTENSION_NAME=jupyterlab-s3-browser
NB_EXTENSION_NAME=widgetsnbextension
#SERVER_EXTENSION_NAME=aws-jupyter-proxy

source /home/ec2-user/anaconda3/bin/activate JupyterSystemEnv

jupyter labextension install $LAB_EXTENSION_NAME
python -m pip install $LAB_EXTENSION_NAME
jupyter serverextension enable --py $LAB_EXTENSION_NAME

pip install ipywidgets
jupyter nbextension enable $NB_EXTENSION_NAME --py --sys-prefix

#pip install $SERVER_EXTENSION_NAME
#jupyter serverextension enable --py aws_jupyter_proxy --sys-prefix
# https://aimstack.readthedocs.io/en/latest/using/sagemaker_notebook_ui.html
pip uninstall --yes nbserverproxy
pip install git+https://github.com/aimhubio/jupyter-server-proxy
pip install aim
# initctl restart jupyter-server --no-wait

source /home/ec2-user/anaconda3/bin/deactivate
EOF


echo "Auto stop to save cost ..."
IDLE_TIME=10700
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


echo "Restart jupyter-server ..."
sudo systemctl daemon-reload
sudo systemctl restart jupyter-server