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
echo "  Install Maven ......"
echo "==============================================="
wget https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz -O /tmp/apache-maven-3.8.6-bin.tar.gz
sudo tar xzvf /tmp/apache-maven-3.8.6-bin.tar.gz -C /opt
cat >> ~/.bashrc <<EOF
export PATH="/opt/apache-maven-3.8.6/bin:$PATH"
EOF
source ~/.bashrc
mvn --version


echo "==============================================="
echo "  Install ec2-instance-selector ......"
echo "==============================================="
curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.3.3/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
chmod +x ./ec2-instance-selector
mkdir -p $HOME/bin && mv ./ec2-instance-selector $HOME/bin/ec2-instance-selector


echo "==============================================="
echo "  Install siege ......"
echo "==============================================="
sudo yum install siege -y
siege -V
#siege -q -t 15S -c 200 -i URL
#ab -c 500 -n 30000 http://$(kubectl get ing -n front-end --output=json | jq -r .items[].status.loadBalancer.ingress[].hostname)/


echo "==============================================="
echo "  Install terraform ......"
echo "==============================================="
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install terraform -y
echo "alias tf='terraform'" >> ~/.bashrc
echo "alias tfp='terraform plan -out tfplan'" >> ~/.bashrc
echo "alias tfa='terraform apply --auto-approve'" >> ~/.bashrc # terraform apply tfplan
source ~/.bashrc
terraform --version


echo "==============================================="
echo "  Install Go ......"
echo "==============================================="
sudo yum install golang -y
export GOPATH=$(go env GOPATH)
echo 'export GOPATH='${GOPATH} >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc
go version


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
echo "  Set Aliases ......"
echo "==============================================="
echo "alias c='clear'" | tee -a ~/.bashrc
echo "alias b='/bin/bash'" | tee -a ~/.bashrc
echo "alias cds='cd /home/ec2-user/SageMaker'" | tee -a ~/.bashrc
echo "alias saj='source activate JupyterSystemEnv'" | tee -a ~/.bashrc
echo "alias sd='source deactivate'" | tee -a ~/.bashrc
source ~/.bashrc


# 最后再执行一次 source
echo "source .bashrc"
shopt -s expand_aliases
source ~/.bashrc
