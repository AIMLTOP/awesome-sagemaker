# 参考
# https://github.com/fmmasood/eks-cli-init-tools/blob/main/cli_tools.sh
WORKING_DIR=/home/ec2-user/SageMaker/custom
mkdir -p "$WORKING_DIR"


echo "==============================================="
echo "  Config envs ......"
echo "==============================================="
export AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bashrc
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bashrc
aws configure set default.region ${AWS_REGION}
aws configure get default.region
aws configure set region $AWS_REGION
source ~/.bashrc
aws sts get-caller-identity


echo "==============================================="
echo "  pyenv ......"
echo "==============================================="
# https://github.com/pyenv/pyenv-installer
curl https://pyenv.run | bash
# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"


# 辅助工具
echo "==============================================="
echo "  Install jq, envsubst (from GNU gettext utilities) and bash-completion ......"
echo "==============================================="
# moreutils: The command sponge allows us to read and write to the same file (cat a.txt|sponge a.txt)
sudo amazon-linux-extras install epel -y
sudo yum -y install bash-completion jq gettext moreutils


# 更新 awscli 并配置自动完成
echo "==============================================="
echo "  Upgrade awscli to v2 ......"
echo "==============================================="
sudo mv /bin/aws /bin/aws1
sudo mv ~/anaconda3/bin/aws ~/anaconda3/bin/aws1
ls -l /usr/local/bin/aws
rm -fr awscliv2.zip aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
AWS_COMPLETER=$(which aws_completer)
echo $SHELL
cat >> ~/.bashrc <<EOF
alias a=aws
complete -C '${AWS_COMPLETER}' aws
complete -C '${AWS_COMPLETER}' a
EOF
source ~/.bashrc
aws --version


# 安装 awscurl 工具 https://github.com/okigan/awscurl
echo "==============================================="
echo "  Install awscurl ......"
echo "==============================================="
cat >> ~/.bashrc <<EOF
export PATH=\$PATH:\$HOME/.local/bin:\$HOME/bin:/usr/local/bin
EOF
source ~/.bashrc
sudo pip install awscurl
awscurl -h


# 安装 session-manager 插件
echo "==============================================="
echo "  Install session-manager ......"
echo "==============================================="
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo yum install -y session-manager-plugin.rpm
session-manager-plugin


echo "==============================================="
echo "  Install siege ......"
echo "==============================================="
sudo yum install siege -y
siege -V
#siege -q -t 15S -c 200 -i URL
#ab -c 500 -n 30000 http://$(kubectl get ing -n front-end --output=json | jq -r .items[].status.loadBalancer.ingress[].hostname)/


echo "==============================================="
echo "  Install Go ......"
echo "==============================================="
# sudo yum install golang -y
# sudo yum install golang --installroot $WORKING_DIR/go -y
# go version


echo "==============================================="
echo "  Install ccat ......"
echo "==============================================="
go install github.com/owenthereal/ccat@latest


echo "==============================================="
echo "  Install telnet ......"
echo "==============================================="
sudo yum -y install telnet


echo "==============================================="
echo "  Docker Compose ......"
echo "==============================================="
#sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o $WORKING_DIR/docker-compose
sudo chmod +x $WORKING_DIR/docker-compose
$WORKING_DIR/docker-compose version


echo "==============================================="
echo "  Install sam cli ......"
echo "==============================================="
wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
sudo ./sam-installation/install
sam --version


echo "==============================================="
echo "  Install nodejs ......"
echo "==============================================="
#v18 got error
#node: /lib64/libm.so.6: version `GLIBC_2.27' not found (required by node)
#node: /lib64/libc.so.6: version `GLIBC_2.28' not found (required by node)
#nvm uninstall v18.12.1
#curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
#source ~/.bashrc
##nvm install --lts
#nvm install 16
#node -e "console.log('Running Node.js ' + process.version)"
#npm install -g esbuild
## perfer yum
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install nodejs gcc-c++ make -y
node -v


echo "==============================================="
echo "  Install netron ......"
echo "==============================================="
#https://github.com/lutzroeder/netron
pip install netron
netron --version
# netron [FILE] or netron.start('[FILE]').


echo "==============================================="
echo " s5cmd ......"
echo "==============================================="
#https://github.com/peak/s5cmd
export S5CMD_URL=$(curl -s https://api.github.com/repos/peak/s5cmd/releases/latest \
| grep "browser_download_url.*_Linux-64bit.tar.gz" \
| cut -d : -f 2,3 \
| tr -d \")
# echo $S5CMD_URL
wget $S5CMD_URL -O $WORKING_DIR/s5cmd.tar.gz
sudo tar xzvf $WORKING_DIR/s5cmd.tar.gz -C $WORKING_DIR
$WORKING_DIR/s5cmd version


echo "==============================================="
echo "  Install more Extensions ......"
echo "==============================================="
#https://medium.com/@shivangisareen/for-anyone-using-jupyter-notebook-installing-packages-18a9468d0c1c
#https://jakevdp.github.io/blog/2017/12/05/installing-python-packages-from-jupyter/#The-Details:-Why-is-Installation-from-Jupyter-so-Messy?
# conda install -c conda-forge nodejs
source activate JupyterSystemEnv # virtual environment directory and the virtualenv is now activated

# globally install packages
#import sys
#!{sys.executable} -m pip install <package_name> or !conda install --yes --prefix {sys.prefix} <package_name>
# python -m ipykernel install --user --name myenv --display-name "Python (myenv)"

# jupyterlab-lsp
# pip install jupyterlab-lsp
# pip install 'python-lsp-server[all]'
# jupyter server extension enable --user --py jupyter_lsp

# S3 browser
jupyter labextension install jupyterlab-s3-browser
# pip install jupyterlab-s3-browser
python -m pip install jupyterlab-s3-browser
jupyter serverextension enable --py jupyterlab_s3_browser

# https://github.com/lckr/jupyterlab-variableInspector
pip install lckr-jupyterlab-variableinspector

# https://github.com/matplotlib/ipympl
pip install ipympl

# https://github.com/aquirdTurtle/Collapsible_Headings
pip install aquirdturtle_collapsible_headings

# https://github.com/QuantStack/jupyterlab-drawio
# pip install jupyterlab-drawio
python -m pip install jupyterlab-drawio

# https://github.com/jtpio/jupyterlab-system-monitor
pip install jupyterlab-system-monitor

# https://github.com/deshaw/jupyterlab-execute-time
pip install jupyterlab_execute_time

#sudo systemctl daemon-reload
#sudo systemctl restart jupyter-server
source deactivate


echo "==============================================="
echo " Persistant Conda ......"
echo "==============================================="
# https://docs.conda.io/en/latest/miniconda.html
# https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/persistent-conda-ebs/on-create.sh
# installs a custom, persistent installation of conda on the Notebook Instance's EBS volume, and ensures
# The on-create script downloads and installs a custom conda installation to the EBS volume via Miniconda. Any relevant
# packages can be installed here.
#   1. ipykernel is installed to ensure that the custom environment can be used as a Jupyter kernel   
#   2. Ensure the Notebook Instance has internet connectivity to download the Miniconda installer
sudo -u ec2-user -i <<'EOF'
unset SUDO_UID

# Install a separate conda installation via Miniconda
WORKING_DIR=/home/ec2-user/SageMaker/custom
mkdir -p "$WORKING_DIR"
# wget https://repo.anaconda.com/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh -O "$WORKING_DIR/miniconda.sh"
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$WORKING_DIR/miniconda.sh"
bash "$WORKING_DIR/miniconda.sh" -b -u -p "$WORKING_DIR/miniconda" 
rm -rf "$WORKING_DIR/miniconda.sh"
EOF
echo "Download custom kernel scripts"
wget https://raw.githubusercontent.com/AIMLTOP/awesome-sagemaker/main/lifecycle/kernelPython3.9.sh -O /home/ec2-user/SageMaker/custom/kernelPython3.9.sh
wget https://raw.githubusercontent.com/AIMLTOP/awesome-sagemaker/main/lifecycle/kernelPython3.8.sh -O /home/ec2-user/SageMaker/custom/kernelPython3.8.sh


echo "==============================================="
echo " VS Code ......"
echo "==============================================="
# https://aws.amazon.com/blogs/machine-learning/host-code-server-on-amazon-sagemaker/
# curl -L https://github.com/aws-samples/amazon-sagemaker-codeserver/releases/download/v0.1.5/amazon-sagemaker-codeserver-0.1.5.tar.gz -o /home/ec2-user/SageMaker/custom/amazon-sagemaker-codeserver-0.1.5.tar.gz
# tar -xvzf /home/ec2-user/SageMaker/custom/amazon-sagemaker-codeserver-0.1.5.tar.gz -d /home/ec2-user/SageMaker/custom/ 
# cd /home/ec2-user/SageMaker/custom/amazon-sagemaker-codeserver/install-scripts/notebook-instances
# chmod +x *.sh
# sudo ./install-codeserver.sh
# sudo ./setup-codeserver.sh
# Another way
# conda install -y -c conda-forge code-server
# code-server --auth none


echo "==============================================="
echo "  Cost Saving ......"
echo "==============================================="
echo "Fetching the autostop script"
wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py -O /home/ec2-user/SageMaker/custom/autostop.py


echo "==============================================="
echo "  Shell Scripts ......"
echo "==============================================="
echo "Donwload sh scripts ..."
wget https://raw.githubusercontent.com/AIMLTOP/awesome-sagemaker/main/utils/re-path -O /home/ec2-user/SageMaker/custom/re-path
wget https://raw.githubusercontent.com/AIMLTOP/awesome-sagemaker/main/utils/re-kernel -O /home/ec2-user/SageMaker/custom/re-kernel
wget https://raw.githubusercontent.com/AIMLTOP/awesome-sagemaker/main/utils/re-bashrc -O /home/ec2-user/SageMaker/custom/re-bashrc
sudo chmod +x /home/ec2-user/SageMaker/custom/re*
sudo chmod +x /home/ec2-user/SageMaker/custom/*.sh
sudo chown ec2-user:ec2-user /home/ec2-user/SageMaker/custom/ -R
# 再执行一次 source
echo "source ~/.bashrc"
shopt -s expand_aliases
source ~/.bashrc


echo "==============================================="
echo "  Referesh bashrc ......"
echo "==============================================="
./re-bashrc