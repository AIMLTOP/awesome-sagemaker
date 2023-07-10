# 参考
# https://github.com/fmmasood/eks-cli-init-tools/blob/main/cli_tools.sh

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


# More tools
echo "==============================================="
echo "  Install yq for yaml processing ......"
echo "==============================================="
echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc


echo "==============================================="
echo "  Install siege ......"
echo "==============================================="
sudo yum install siege -y
siege -V
#siege -q -t 15S -c 200 -i URL
#ab -c 500 -n 30000 http://$(kubectl get ing -n front-end --output=json | jq -r .items[].status.loadBalancer.ingress[].hostname)/


# echo "==============================================="
# echo "  Install Go ......"
# echo "==============================================="
# sudo yum install golang -y
# export GOPATH=$(go env GOPATH)
# echo 'export GOPATH='${GOPATH} >> ~/.bashrc
# echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
# source ~/.bashrc
# go version


echo "==============================================="
echo "  Install ccat ......"
echo "==============================================="
go install github.com/owenthereal/ccat@latest
cat >> ~/.bashrc <<EOF
alias cat=ccat
EOF
source ~/.bashrc


echo "==============================================="
echo "  Install telnet ......"
echo "==============================================="
sudo yum -y install telnet


echo "==============================================="
echo "  Cofing dfimage ......"
echo "==============================================="
cat >> ~/.bashrc <<EOF
alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage"  
EOF
source ~/.bashrc
# dfimage -sV=1.36 nginx:latest 


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
wget $S5CMD_URL -O /tmp/s5cmd.tar.gz
sudo mkdir -p /opt/s5cmd/
sudo tar xzvf /tmp/s5cmd.tar.gz -C /opt/s5cmd
cat >> ~/.bashrc <<EOF
export PATH="/opt/s5cmd:$PATH"
alias s5='s5cmd'
EOF
source ~/.bashrc
s5cmd version


echo "==============================================="
echo "  Install more Extensions ......"
echo "==============================================="
# conda install -c conda-forge nodejs
source activate JupyterSystemEnv

# jupyterlab-lsp
pip install jupyterlab-lsp
pip install 'python-lsp-server[all]'
jupyter server extension enable --user --py jupyter_lsp

# S3 browser
jupyter labextension install jupyterlab-s3-browser
pip install jupyterlab-s3-browser
jupyter serverextension enable --py jupyterlab_s3_browser

# https://github.com/lckr/jupyterlab-variableInspector
pip install lckr-jupyterlab-variableinspector

# https://github.com/matplotlib/ipympl
pip install ipympl

# https://github.com/aquirdTurtle/Collapsible_Headings
pip install aquirdturtle_collapsible_headings

# https://github.com/QuantStack/jupyterlab-drawio
pip install jupyterlab-drawio

# https://github.com/jtpio/jupyterlab-system-monitor
pip install jupyterlab-system-monitor

# https://github.com/deshaw/jupyterlab-execute-time
pip install jupyterlab_execute_time

#sudo systemctl daemon-reload
#sudo systemctl restart jupyter-server
source deactivate


echo "==============================================="
echo "  Set Aliases ......"
echo "==============================================="
echo "Create sh profile  ..."
echo "alias b='/bin/bash'" > ~/.profile
source ~/.profile
echo "alias c='clear'" | tee -a ~/.bashrc
echo "alias b='/bin/bash'" | tee -a ~/.bashrc
echo "alias cds='cd /home/ec2-user/SageMaker'" | tee -a ~/.bashrc
echo "alias saj='source activate JupyterSystemEnv'" | tee -a ~/.bashrc
echo "alias sd='source deactivate'" | tee -a ~/.bashrc
source ~/.bashrc


# 最后再执行一次 source
echo "source ~/.bashrc"
shopt -s expand_aliases
source ~/.profile
source ~/.bashrc