# Create a custom conda environment
WORKING_DIR=/home/ec2-user/SageMaker/custom
source "$WORKING_DIR/miniconda/bin/activate"
KERNEL_NAME="python_3.8"
PYTHON="3.8"
conda create --yes --name "$KERNEL_NAME" python="$PYTHON"
conda activate "$KERNEL_NAME"
# pip install --quiet ipykernel
conda install -c conda-forge nb_conda_kernels -y
# conda install nb_conda_kernels -y
conda install -n "$KERNEL_NAME" ipykernel ipywidgets -y
python -m pip install "$KERNEL_NAME" --quiet ipykernel 
# Customize these lines as necessary to install the required packages
conda install --yes numpy
pip install --quiet boto3
# conda install --yes Pillow pandas numpy scipy matplotlib jupyter scikit-learn seaborn beautifulsoup4 sagemaker
#conda install --yes Pillow==9.1.1 pandas==1.4.2 numpy==1.22.4 scipy==1.7.3
# pip install tensorflow==2.6.2 tensorflow-datasets
conda deactivate

# https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/persistent-conda-ebs/on-start.sh
# Optionally, uncomment these lines to disable SageMaker-provided Conda functionality.'
# echo "c.EnvironmentKernelSpecManager.use_conda_directly = False" >> /home/ec2-user/.jupyter/jupyter_notebook_config.py
# rm /home/ec2-user/.condarc