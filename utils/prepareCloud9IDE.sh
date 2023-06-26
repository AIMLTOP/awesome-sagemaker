#https://github.com/aws-samples/aws-do-eks
#https://github.com/aws-samples/aws-do-eks/tree/main/Container-Root/eks/ops/setup
echo "==============================================="
echo "  Config envs ......"
echo "==============================================="
export AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/')
#export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
#export ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`

test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set

echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bashrc
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bashrc
aws configure set default.region ${AWS_REGION}
aws configure get default.region
aws configure set region $AWS_REGION

source ~/.bashrc
aws sts get-caller-identity


echo "==============================================="
echo "  Config Cloud9 ......"
echo "==============================================="
aws cloud9 update-environment --environment-id $C9_PID --managed-credentials-action DISABLE
rm -vf ${HOME}/.aws/credentials
npm install -g c9 # Install c9 to open files in cloud9 
# example  c9 open ~/package.json


echo "==============================================="
echo "  Upgrade Python to 3.8 ......"
echo "==============================================="
sudo amazon-linux-extras install python3.8 -y
python -m ensurepip --upgrade --user
# sudo yum update -y
cat >> ~/.bashrc <<EOF
alias python='/usr/bin/python3.8'
EOF
source ~/.bashrc

# Install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py; python get-pip.py; rm -f get-pip.py


echo "==============================================="
echo "  Install eksctl ......"
echo "==============================================="
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
# 配置自动完成
cat >> ~/.bashrc <<EOF
. <(eksctl completion bash)
alias e=eksctl
complete -F __start_eksctl e
EOF
source ~/.bashrc


echo "==============================================="
echo "  Install eks anywhere ......"
echo "==============================================="
export EKSA_RELEASE="0.14.3" OS="$(uname -s | tr A-Z a-z)" RELEASE_NUMBER=30
curl "https://anywhere-assets.eks.amazonaws.com/releases/eks-a/${RELEASE_NUMBER}/artifacts/eks-a/v${EKSA_RELEASE}/${OS}/amd64/eksctl-anywhere-v${EKSA_RELEASE}-${OS}-amd64.tar.gz" \
    --silent --location \
    | tar xz ./eksctl-anywhere
sudo mv ./eksctl-anywhere /usr/local/bin/
eksctl anywhere version


# 更新 awscli 并配置自动完成
echo "==============================================="
echo "  Upgrade awscli to v2 ......"
echo "==============================================="
sudo mv /bin/aws /bin/aws1
sudo mv ~/anaconda3/bin/aws ~/anaconda3/bin/aws1
ls -l /usr/local/bin/aws
rm -fr awscliv2.zip aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install
which aws_completer
echo $SHELL
cat >> ~/.bashrc <<EOF
complete -C '/usr/local/bin/aws_completer' aws
EOF
source ~/.bashrc
aws --version
# container way
# https://aws.amazon.com/blogs/developer/new-aws-cli-v2-docker-images-available-on-amazon-ecr-public/
# docker run --rm -it public.ecr.aws/aws-cli/aws-cli:2.9.1 --version aws-cli/2.9.1 Python/3.9.11 Linux/5.10.47-linuxkit docker/aarch64.amzn.2 prompt/off


echo "==============================================="
echo "  Install kubectl ......"
echo "==============================================="
# 安装 kubectl 并配置自动完成
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# curl -LO https://dl.k8s.io/release/v1.25.6/bin/linux/amd64/kubectl -o "/tmp/kubectl"
mv kubectl /tmp/
sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
cat >> ~/.bashrc <<EOF
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
EOF
source ~/.bashrc
kubectl version --client
# Enable some kubernetes aliases
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
sudo curl https://raw.githubusercontent.com/blendle/kns/master/bin/kns -o /usr/local/bin/kns && sudo chmod +x $_
sudo curl https://raw.githubusercontent.com/blendle/kns/master/bin/ktx -o /usr/local/bin/ktx && sudo chmod +x $_
# echo "alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L beta.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name -L karpenter.sh/capacity-type'" | tee -a ~/.bashrc
#echo "alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L beta.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone'" | tee -a ~/.bashrc
echo "alias kk='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L karpenter.sh/capacity-type -L node.kubernetes.io/instance-type -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name'" | tee -a ~/.bashrc
echo "alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L node.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone'" | tee -a ~/.bashrc
# echo "alias kgnk='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L node.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name -L karpenter.sh/capacity-type'" | tee -a ~/.bashrc
echo "alias kgp='kubectl get po -o wide'" | tee -a ~/.bashrc
echo "alias kgd='kubectl get deployment -o wide'" | tee -a ~/.bashrc
echo "alias kgs='kubectl get svc -o wide'" | tee -a ~/.bashrc
echo "alias kdn='kubectl describe node'" | tee -a ~/.bashrc
echo "alias kdp='kubectl describe po'" | tee -a ~/.bashrc
echo "alias kdd='kubectl describe deployment'" | tee -a ~/.bashrc
echo "alias kds='kubectl describe svc'" | tee -a ~/.bashrc
echo 'export dry="--dry-run=client -o yaml"' | tee -a ~/.bashrc
echo "alias ka='kubectl apply'" | tee -a ~/.bashrc
echo "alias kr='kubectl run $dry'" | tee -a ~/.bashrc
echo "alias ke='kubectl explain'" | tee -a ~/.bashrc
source ~/.bashrc


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
echo "  EKS Pod Information Collector ......"
echo "==============================================="
# https://github.com/awslabs/amazon-eks-ami/tree/master/log-collector-script/linux
sudo curl -o /usr/local/bin/epic https://raw.githubusercontent.com/aws-samples/eks-pod-information-collector/main/eks-pod-information-collector.sh
sudo chmod +x /usr/local/bin/epic
# epic -p <Pod_Name> -n <Pod_Namespace>
# epic --podname <Pod_Name> --namespace <Pod_Namespace>


echo "==============================================="
echo "  Install krew ......"
echo "==============================================="
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

cat >> ~/.bashrc <<EOF
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
EOF
source ~/.bashrc
kubectl krew update
kubectl krew install resource-capacity
kubectl krew install count
kubectl krew install get-all
kubectl krew install ktop
kubectl krew install ctx # kubectx
kubectl krew install ns # kubens
# kubectl krew install lineage
#kubectl krew install custom-cols
#kubectl krew install explore
#kubectl krew install flame
#kubectl krew install foreach
#kubectl krew install fuzzy
#kubectl krew index add kvaps https://github.com/kvaps/krew-index
#kubectl krew install kvaps/node-shell
kubectl krew list
# k resource-capacity --util --sort cpu.util 
# k resource-capacity --pods --util --pod-labels app.kubernetes.io/name=aws-node --namespace kube-system --sort cpu.util
# k get po -l app.kubernetes.io/name=aws-node -n kube-system -o wide
# kubectl ktop
# kubectl lineage --version
# k get-all
# k count pod
# k node-shell <node>


echo "==============================================="
echo "  Install kubetail ......"
echo "==============================================="
curl -o /tmp/kubetail https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
chmod +x /tmp/kubetail
sudo mv /tmp/kubetail /usr/local/bin/kubetail
cat >> ~/.bashrc <<EOF
alias kt=kubetail
EOF
source ~/.bashrc


# 安装 helm
echo "==============================================="
echo "  Install helm ......"
echo "==============================================="
curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh
helm version
helm repo add stable https://charts.helm.sh/stable


# 安装 awscurl 工具 https://github.com/okigan/awscurl
echo "==============================================="
echo "  Install awscurl ......"
echo "==============================================="
cat >> ~/.bashrc <<EOF
export PATH=\$PATH:\$HOME/.local/bin:\$HOME/bin:/usr/local/bin
EOF
source ~/.bashrc
sudo python3 -m pip install awscurl


# 安装 session-manager 插件
echo "==============================================="
echo "  Install session-manager ......"
echo "==============================================="
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "/tmp/session-manager-plugin.rpm"
sudo yum install -y /tmp/session-manager-plugin.rpm
session-manager-plugin


# 辅助工具
echo "==============================================="
echo "  Install jq, envsubst (from GNU gettext utilities) and bash-completion ......"
echo "==============================================="
# moreutils: The command sponge allows us to read and write to the same file (cat a.txt|sponge a.txt)
sudo yum -y install jq gettext bash-completion moreutils


echo "==============================================="
echo "  Install yq for yaml processing ......"
echo "==============================================="
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq
# echo 'yq() {
#   docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
# }' | tee -a ~/.bashrc && source ~/.bashrc


echo "==============================================="
echo "  Install k9s a Kubernetes CLI To Manage Your Clusters In Style ......"
echo "==============================================="
curl -sS https://webinstall.dev/k9s | bash
# 参考 https://segmentfault.com/a/1190000039755239


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
echo "  Install ec2-instance-selector ......"
echo "==============================================="
#curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.3.3/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
# curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.4.0/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.4.1/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
chmod +x ./ec2-instance-selector
mkdir -p $HOME/bin && mv ./ec2-instance-selector $HOME/bin/ec2-instance-selector
ec2-instance-selector --version
# ec2-instance-selector -o interactive
cat >> ~/.bashrc <<EOF
alias ec2s=ec2-instance-selector
EOF
source ~/.bashrc


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
echo "  Config Go ......"
echo "==============================================="
go version
export GOPATH=$(go env GOPATH)
echo 'export GOPATH='${GOPATH} >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc


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
echo "  Install wildq ......"
echo "==============================================="
# wildq: Tool on-top of jq to manipulate INI files
sudo pip3 install wildq
# cat file.ini \
#   |wildq -i ini -M '.Key = "value"' \
#   |sponge file.ini


echo "==============================================="
echo "  Install java 8 ......"
echo "==============================================="
sudo amazon-linux-extras enable corretto8
# sudo yum clean metadata
sudo yum install java-1.8.0-amazon-corretto-devel -y
#sudo alternatives --config java
#sudo update-alternatives --config javac
java -version
javac -version


echo "==============================================="
echo "  Expand disk space ......"
echo "==============================================="
wget https://raw.githubusercontent.com/DATACNTOP/streaming-analytics/main/utils/scripts/resize-ebs.sh -O /tmp/resize-ebs.sh
chmod +x /tmp/resize-ebs.sh
/tmp/resize-ebs.sh 500


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
echo "  Install Kubectl EKS Plugin ......"
echo "==============================================="
# git clone https://github.com/surajincloud/kubectl-eks.git
# cd kubectl-eks
# make
# sudo mv ./kubectl-eks /usr/local/bin
# cd ..
kubectl krew index add surajincloud git@github.com:surajincloud/krew-index.git
kubectl krew search eks
kubectl krew install surajincloud/kubectl-eks
# https://surajincloud.github.io/kubectl-eks/usage/
# kubectl eks irsa
# kubectl eks irsa -n kube-system
# kubectl eks ssm <name-of-the-node>
# kubectl eks nodes
# kubectl eks suggest-ami


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


#https://github.com/awslabs/eks-node-viewer
# echo "==============================================="
# echo "  Install eks-node-viewer ......"
# echo "==============================================="
go env -w GOPROXY=direct
go install github.com/awslabs/eks-node-viewer/cmd/eks-node-viewer@latest
export GOBIN=${GOBIN:-~/go/bin}
echo "export PATH=\$PATH:$GOBIN" >> ~/.bashrc
cat >> ~/.bashrc <<EOF
alias nv='eks-node-viewer'
EOF
source ~/.bashrc


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


# echo "==============================================="
# echo " S3 Mountpoint ......"
# echo "==============================================="
# sudo yum install fuse fuse-devel cmake3 clang-devel -y
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/sh.rustup.rs
# sh /tmp/sh.rustup.rs
# source "$HOME/.cargo/env"
# git clone --recurse-submodules https://github.com/awslabs/mountpoint-s3.git /tmp/mountpoint-s3
# cd /tmp/mountpoint-s3
# cargo build --release
# sudo cp ./target/release/mount-s3 /usr/local/bin/


echo "==============================================="
echo "  Network Utilites ......"
echo "==============================================="
#https://repost.aws/knowledge-center/network-issue-vpc-onprem-ig
sudo yum install mtr traceroute -y


echo "==============================================="
echo " dos2unix ......"
echo "==============================================="
sudo yum install dos2unix -y
# dos2unix xxx.sh


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
EOF
source ~/.bashrc
s5cmd version


echo "==============================================="
echo " node-latency-for-k8s ......"
echo "==============================================="
# https://github.com/awslabs/node-latency-for-k8s
[[ `uname -m` == "aarch64" ]] && ARCH="arm64" || ARCH="amd64"
OS=`uname | tr '[:upper:]' '[:lower:]'`
wget https://github.com/awslabs/node-latency-for-k8s/releases/download/v0.1.10/node-latency-for-k8s_0.1.10_${OS}_${ARCH}.tar.gz -O /tmp/node-latency-for-k8s.tar.gz
sudo mkdir -p /opt/node-latency-for-k8s
sudo tar xzvf /tmp/node-latency-for-k8s.tar.gz -C /opt/node-latency-for-k8s
chmod +x /opt/node-latency-for-k8s/node-latency-for-k8s
cat >> ~/.bashrc <<EOF
export PATH="/opt/node-latency-for-k8s:$PATH"
EOF
source ~/.bashrc
node-latency-for-k8s -h


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
python3 -m pip install  pipx
python3 -m pip install  boto3
python3 -m pipx install resource-lister
# pipx run resource_lister
# python3 -m pipx run resource_lister


echo "==============================================="
echo "  More Aliases ......"
echo "==============================================="
# .vimrc
cat > ~/.vimrc <<EOF
set number
set expandtab
set tabstop=2
set shiftwidth=2
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
EOF

cat >> ~/.bashrc <<EOF
alias c=clear
alias ll='ls -alh --color=auto'
alias jc=/bin/journalctl
export TERM=xterm-256color
EOF
source ~/.bashrc
# journalctl -u kubelet | grep error 

# 最后再执行一次 source
echo "source .bashrc"
shopt -s expand_aliases
source ~/.bashrc