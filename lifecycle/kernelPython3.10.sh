# Create a custom conda environment
# https://stackoverflow.com/questions/39604271/conda-environments-not-showing-up-in-jupyter-notebook
WORKING_DIR=/home/ec2-user/SageMaker/custom
source "$WORKING_DIR/miniconda/bin/activate"
KERNEL_NAME="python_3.10"
PYTHON="3.10"
conda create --yes --prefix "$WORKING_DIR" --name "$KERNEL_NAME" python="$PYTHON" # --name -n
conda activate "$WORKING_DIR/$KERNEL_NAME"
conda install -c conda-forge nb_conda_kernels -y
# conda install nb_conda_kernels -y
# conda install ipykernel -y
conda install -n "$KERNEL_NAME" ipykernel ipywidgets -y
# pip install --quiet ipykernel
python -m pip install --quiet ipykernel
# Customize these lines as necessary to install the required packages
conda install --yes numpy
pip install --quiet boto3
# conda install --yes Pillow==9.1.1 pandas==1.4.2 numpy==1.22.4 scipy==1.7.3
# nohup pip install tensorflow==2.9.0 tensorflow-datasets==4.6.0 &
#conda install --yes tensorflow==2.9.1 tensorflow-datasets==4.6.0
# nohup pip install --quiet boto3 sagemaker &
#pip install sagemaker
# nohup conda install --yes matplotlib jupyter scikit-learn seaborn beautifulsoup4 &
#source deactivate
conda deactivate

# https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/persistent-conda-ebs/on-start.sh
# Optionally, uncomment these lines to disable SageMaker-provided Conda functionality.'
# echo "c.EnvironmentKernelSpecManager.use_conda_directly = False" >> /home/ec2-user/.jupyter/jupyter_notebook_config.py
# rm /home/ec2-user/.condarc