#!/bin/bash

set -e

echo "Setup Custom Kernel ..."

sudo -u ec2-user -i <<'EOF'
unset SUDO_UID
# Install a separate conda installation via Miniconda
WORKING_DIR=/home/ec2-user/SageMaker/custom/tf26-p38
mkdir -p "$WORKING_DIR"
wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.11.0-Linux-x86_64.sh -O "$WORKING_DIR/miniconda.sh"

bash "$WORKING_DIR/miniconda.sh" -b -u -p "$WORKING_DIR/miniconda"
rm -rf "$WORKING_DIR/miniconda.sh"
# Create a custom conda environment
source "$WORKING_DIR/miniconda/bin/activate"
KERNEL_NAME="tf26_p38"
PYTHON="3.8"
conda create --yes --name "$KERNEL_NAME" python="$PYTHON"
conda activate "$KERNEL_NAME"
pip install --quiet ipykernel
# Customize these lines as necessary to install the required packages
# conda install --yes numpy
#conda install --yes Pillow==9.1.1 pandas==1.4.2 numpy==1.22.4 scipy==1.7.3
pip install tensorflow==2.6.2 tensorflow-datasets
pip install --quiet boto3
conda install --yes Pillow pandas numpy scipy matplotlib jupyter scikit-learn seaborn beautifulsoup4 sagemaker
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