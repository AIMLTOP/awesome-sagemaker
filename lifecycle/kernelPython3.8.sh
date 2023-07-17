# Create a custom conda environment
WORKING_DIR=/home/ec2-user/SageMaker/custom
source "$WORKING_DIR/miniconda/bin/activate"
KERNEL_NAME="python_3.8"
PYTHON="3.8"
conda create --yes --name "$KERNEL_NAME" python="$PYTHON"
conda activate "$KERNEL_NAME"
# pip install --quiet ipykernel
python -m pip install --quiet ipykernel 
# Customize these lines as necessary to install the required packages
conda install --yes numpy
pip install --quiet boto3

# https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/persistent-conda-ebs/on-start.sh
# Optionally, uncomment these lines to disable SageMaker-provided Conda functionality.'
# echo "c.EnvironmentKernelSpecManager.use_conda_directly = False" >> /home/ec2-user/.jupyter/jupyter_notebook_config.py
# rm /home/ec2-user/.condarc