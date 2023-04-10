#!/bin/bash

set -e

echo "Setup Custom Kernel ..."
# https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/persistent-conda-ebs/on-create.sh
# https://docs.conda.io/en/latest/miniconda.html
# https://medium.com/@haridada07/creating-persistent-python-kernels-for-sagemaker-63993138ae50
# https://aws.amazon.com/premiumsupport/knowledge-center/sagemaker-lifecycle-script-timeout/
# OVERVIEW
# This script installs a custom, persistent installation of conda on the Notebook Instance's EBS volume, and ensures
# that these custom environments are available as kernels in Jupyter.
#
# The on-create script downloads and installs a custom conda installation to the EBS volume via Miniconda. Any relevant
# packages can be installed here.
#   1. ipykernel is installed to ensure that the custom environment can be used as a Jupyter kernel
#   2. Ensure the Notebook Instance has internet connectivity to download the Miniconda installer


sudo -u ec2-user -i <<'EOF'
unset SUDO_UID
# Install a separate conda installation via Miniconda
WORKING_DIR=/home/ec2-user/SageMaker/custom/tf29-p38
mkdir -p "$WORKING_DIR"
# wget https://repo.anaconda.com/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh -O "$WORKING_DIR/miniconda.sh"
wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.11.0-Linux-x86_64.sh -O "$WORKING_DIR/miniconda.sh"

bash "$WORKING_DIR/miniconda.sh" -b -u -p "$WORKING_DIR/miniconda"
rm -rf "$WORKING_DIR/miniconda.sh"
# Create a custom conda environment
source "$WORKING_DIR/miniconda/bin/activate"
KERNEL_NAME="tf29_p38"
PYTHON="3.8"
conda create --yes --name "$KERNEL_NAME" python="$PYTHON"
conda activate "$KERNEL_NAME"
pip install --quiet ipykernel
# Customize these lines as necessary to install the required packages
# conda install --yes numpy
conda install --yes Pillow==9.1.1 pandas==1.4.2 numpy==1.22.4 scipy==1.7.3
nohup pip install tensorflow==2.9.0 tensorflow-datasets==4.6.0 &
#conda install --yes tensorflow==2.9.1 tensorflow-datasets==4.6.0
nohup pip install --quiet boto3 sagemaker &
#pip install sagemaker
nohup conda install --yes matplotlib jupyter scikit-learn seaborn beautifulsoup4 &
#source deactivate
conda deactivate
EOF


echo "Install Extensions ..."
sudo -u ec2-user -i <<'EOF'

# conda install -c conda-forge nodejs
source activate JupyterSystemEnv
jupyter labextension install jupyterlab-s3-browser
pip install jupyterlab-s3-browser
jupyter serverextension enable --py jupyterlab_s3_browser

pip install jupyterlab-lsp
pip install 'python-lsp-server[all]'
jupyter server extension enable --user --py jupyter_lsp
source deactivate
EOF