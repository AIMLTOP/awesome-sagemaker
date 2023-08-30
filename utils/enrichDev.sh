echo "==============================================="
echo "  pyenv ......"
echo "==============================================="
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
cat << 'EOT' >> ~/.bashrc
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
EOT
source ~/.bashrc


echo "==============================================="
echo "  Upgrade Python ......"
echo "==============================================="
## use amazon-linux-extras to install python 3.8
# sudo amazon-linux-extras install python3.8 -y
# python -m ensurepip --upgrade --user
# sudo pip3 install --upgrade pip
# sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
# sudo update-alternatives --set python3 /usr/local/bin/python3.8
## use pyenv to install python 3.9 (about 5 minutes to finish)
sudo yum -y update
sudo yum -y install bzip2-devel xz-devel
pyenv install 3.9.15
pyenv global 3.9.15
export PATH="$HOME/.pyenv/shims:$PATH"
source ~/.bash_profile
python --version


echo "==============================================="
echo "  NodeJS ......"
echo "==============================================="
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
# . ~/.nvm/nvm.sh
# nvm install 16
# node -e "console.log('Running Node.js ' + process.version)"
## utils
# npm list --depth=0
## Redoc https://github.com/Redocly/redoc
# npm i
# npm run watch
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
echo "  SAM ......"
echo "==============================================="
cd /tmp
wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
sudo ./sam-installation/install
sam --version
cd -


echo "==============================================="
echo "  cargo ......"
echo "==============================================="
curl https://sh.rustup.rs -sSf | sh
source ~/.bashrc
sudo yum install -y openssl-devel
cargo install drill


echo "==============================================="
echo "  Cloudscape ......"
echo "==============================================="
# https://cloudscape.design/get-started/integration/using-cloudscape-components/


echo "==============================================="
echo "  Install eks anywhere ......"
echo "==============================================="
export EKSA_RELEASE="0.14.3" OS="$(uname -s | tr A-Z a-z)" RELEASE_NUMBER=30
curl "https://anywhere-assets.eks.amazonaws.com/releases/eks-a/${RELEASE_NUMBER}/artifacts/eks-a/v${EKSA_RELEASE}/${OS}/amd64/eksctl-anywhere-v${EKSA_RELEASE}-${OS}-amd64.tar.gz" \
    --silent --location \
    | tar xz ./eksctl-anywhere
sudo mv ./eksctl-anywhere /usr/local/bin/
eksctl anywhere version


echo "==============================================="
echo "  Install copilot ......"
echo "==============================================="
sudo curl -Lo /usr/local/bin/copilot https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux \
   && sudo chmod +x /usr/local/bin/copilot \
   && copilot --help


echo "==============================================="
echo "  Install App2Container ......"
echo "==============================================="
#https://docs.aws.amazon.com/app2container/latest/UserGuide/start-step1-install.html
#https://aws.amazon.com/blogs/containers/modernize-java-and-net-applications-remotely-using-aws-app2container/
curl -o /tmp/AWSApp2Container-installer-linux.tar.gz https://app2container-release-us-east-1.s3.us-east-1.amazonaws.com/latest/linux/AWSApp2Container-installer-linux.tar.gz
sudo tar xvf /tmp/AWSApp2Container-installer-linux.tar.gz -C /tmp
# sudo ./install.sh
echo y |sudo /tmp/install.sh
sudo app2container --version
cat >> ~/.bashrc <<EOF
alias a2c="sudo app2container"
EOF
source ~/.bashrc
a2c help
curl -o /tmp/optimizeImage.zip https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/samples/p-attach/dc756bff-1fcd-4fd2-8c4f-dc494b5007b9/attachments/attachment.zip
sudo unzip /tmp/optimizeImage.zip -d /tmp/optimizeImage
sudo chmod 755 /tmp/optimizeImage/optimizeImage.sh
sudo mv /tmp/optimizeImage/optimizeImage.sh /usr/local/bin/optimizeImage.sh
optimizeImage.sh -h


echo "==============================================="
echo "  Install kube-no-trouble (kubent) ......"
echo "==============================================="
# https://github.com/doitintl/kube-no-trouble
# https://medium.doit-intl.com/kubernetes-how-to-automatically-detect-and-deal-with-deprecated-apis-f9a8fc23444c
sh -c "$(curl -sSL https://git.io/install-kubent)"


# echo "==============================================="
# echo "  Install IAM Authenticator ......"
# echo "==============================================="
## https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
## curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
## curl -o aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64
# curl -o aws-iam-authenticator https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
# chmod +x ./aws-iam-authenticator
# mkdir -p $HOME/bin && mv ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
# echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
# source ~/.bashrc
# aws-iam-authenticator help


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
echo "  Install kubescape ......"
echo "==============================================="
# curl -s https://raw.githubusercontent.com/armosec/kubescape/master/install.sh | /bin/bash
curl -s https://raw.githubusercontent.com/armosec/kubescape/master/install.sh -o "/tmp/kubescape.sh"
/tmp/kubescape.sh


echo "==============================================="
echo "  Install kind ......"
echo "==============================================="
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.17.0/kind-$(uname)-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


# echo "==============================================="
# echo "  Install Flux CLI ......"
# echo "==============================================="
# curl -s https://fluxcd.io/install.sh | sudo bash
# flux --version


# echo "==============================================="
# echo "  Install argocd ......"
# echo "==============================================="
# curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
# sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
# rm argocd-linux-amd64
# argocd version --client
export ARGO_VERSION="v3.4.9"
curl -sLO https://github.com/argoproj/argo-workflows/releases/download/${ARGO_VERSION}/argo-linux-amd64.gz
gunzip argo-linux-amd64.gz
chmod +x argo-linux-amd64
sudo mv ./argo-linux-amd64 /usr/local/bin/argo
argo version
rm -fr argo-linux-amd64.gz


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
echo "  Install ccat ......"
echo "==============================================="
go install github.com/owenthereal/ccat@latest
cat >> ~/.bashrc <<EOF
alias cat=ccat
EOF
source ~/.bashrc


echo "==============================================="
echo "  Install ParallelCluster ......"
echo "==============================================="
if ! command -v pcluster &> /dev/null
then
  echo ">> pcluster is missing, reinstalling it"
  sudo pip3 install 'aws-parallelcluster'
else
  echo ">> Pcluster $(pcluster version) found, nothing to install"
fi
pcluster version


echo "==============================================="
echo "  Install docker buildx ......"
echo "==============================================="
# https://aws.amazon.com/blogs/compute/how-to-quickly-setup-an-experimental-environment-to-run-containers-on-x86-and-aws-graviton2-based-amazon-ec2-instances-effort-to-port-a-container-based-application-from-x86-to-graviton2/
# https://docs.docker.com/build/buildx/install/
# export DOCKER_BUILDKIT=1
# docker build --platform=local -o . git://github.com/docker/buildx
DOCKER_BUILDKIT=1 docker build --platform=local -o . "https://github.com/docker/buildx.git"
mkdir -p ~/.docker/cli-plugins
mv buildx ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx
docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx ls


# 编译安装时间较久，如需要请手动复制脚本安装
# echo "==============================================="
# echo "  Install kmf ......"
# echo "==============================================="
# git clone https://github.com/awslabs/aws-kubernetes-migration-factory
# cd aws-kubernetes-migration-factory/
# sudo go build -o /usr/local/bin/kmf
# cd ..
# kmf -h


echo "==============================================="
echo "  Install graphviz ......"
echo "==============================================="
sudo yum -y install graphviz


# echo "==============================================="
# echo "  Install clusterctl ......"
# echo "==============================================="
# curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.2.4/clusterctl-linux-amd64 -o clusterctl
# chmod +x ./clusterctl
# sudo mv ./clusterctl /usr/local/bin/clusterctl
# clusterctl version


# echo "==============================================="
# echo "  Install clusterawsadm ......"
# echo "==============================================="
# curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/v1.5.0/clusterawsadm-linux-amd64 -o clusterawsadm
# chmod +x clusterawsadm
# sudo mv clusterawsadm /usr/local/bin
# clusterawsadm version


echo "==============================================="
echo "  Install lynx ......"
echo "==============================================="
sudo yum install lynx -y


# echo "==============================================="
# echo "  Install kube-ps1.sh ......"
# echo "==============================================="
# curl -L -o ~/kube-ps1.sh https://github.com/jonmosco/kube-ps1/raw/master/kube-ps1.sh
# cat << EOF >> ~/.bashrc
# alias kon='touch ~/.kubeon; source ~/.bashrc'
# alias koff='rm -f ~/.kubeon; source ~/.bashrc'
# if [ -f ~/.kubeon ]; then
#         source ~/kube-ps1.sh
#         PS1='[\u@\h \W \$(kube_ps1)]\$ '
# fi
# EOF
# source ~/.bashrc


# echo "==============================================="
# echo "  Cloudwatch Dashboard Generator ......"
# echo "==============================================="
# https://github.com/aws-samples/aws-cloudwatch-dashboard-generator
# mkdir -p ~/environment/sre && cd ~/environment/sre
# # git clone https://github.com/aws-samples/aws-cloudwatch-dashboard-generator.git 
# git clone https://github.com/CLOUDCNTOP/aws-cloudwatch-dashboard-generator.git
# cd aws-cloudwatch-dashboard-generator
# pip install -r r_requirements.txt


echo "==============================================="
echo " krr (Prometheus-based Kubernetes Resource Recommendations) ......"
echo "==============================================="
#https://github.com/robusta-dev/krr


echo "==============================================="
echo " tumx ......"
echo "==============================================="
#https://tmuxcheatsheet.com/
#https://github.com/MarcoLeongDev/handsfree-stable-diffusion


echo "==============================================="
echo " eksdemo ......"
echo "==============================================="
# https://github.com/awslabs/eksdemo


echo "==============================================="
echo " gettext ......"
echo "==============================================="
#envsubst for environment variables substitution (envsubst is included in gettext package)
#https://yum-info.contradodigital.com/view-package/base/gettext/


echo "==============================================="
echo " kubefirst ......"
echo "==============================================="
# https://github.com/kubefirst/kubefirst
# https://docs.kubefirst.io/aws/overview


echo "==============================================="
echo " Steampipe ......"
echo "==============================================="
# Visualizing AWS EKS Kubernetes Clusters with Relationship Graphs
# https://dev.to/aws-builders/visualizing-aws-eks-kubernetes-clusters-with-relationship-graphs-46a4
# sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
# steampipe plugin install kubernetes
# git clone https://github.com/turbot/steampipe-mod-kubernetes-insights
# cd steampipe-mod-kubernetes-insights
# steampipe dashboard


echo "==============================================="
echo " resource-lister ......"
echo "==============================================="
# https://github.com/awslabs/resource-lister
python3 -m pip install pipx
python3 -m pip install boto3
python3 -m pipx install resource-lister
# pipx run resource_lister
# python3 -m pipx run resource_lister


echo "==============================================="
echo " kuboard ......"
echo "==============================================="
# https://kuboard.cn/install/v3/install-built-in.html#%E9%83%A8%E7%BD%B2%E8%AE%A1%E5%88%92
LOCAL_IPV4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sudo docker run -d \
  --restart=unless-stopped \
  --name=kuboard \
  -p 80:80/tcp \
  -p 10081:10081/tcp \
  -e KUBOARD_ENDPOINT="http://${LOCAL_IPV4}:80" \
  -e KUBOARD_AGENT_SERVER_TCP_PORT="10081" \
  -v /root/kuboard-data:/data \
  eipwork/kuboard:v3
  # 也可以使用镜像 swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard:v3 ，可以更快地完成镜像下载。
  # 请不要使用 127.0.0.1 或者 localhost 作为内网 IP \
  # Kuboard 不需要和 K8S 在同一个网段，Kuboard Agent 甚至可以通过代理访问 Kuboard Server \


echo "==============================================="
echo "  CDK Version 1.x ......"
echo "==============================================="
# https://www.npmjs.com/package/aws-cdk?activeTab=versions
# npm uninstall aws-cdk
# npm install -g aws-cdk@1.199.0
# npm install -g aws-cdk@1.199.0 --force
cdk --version


# echo "==============================================="
# echo "  KubeVela ......"
# echo "==============================================="
# https://kubevela.io/docs/installation/standalone/#local


# echo "==============================================="
# echo " VS Code ......"
# echo "==============================================="
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
