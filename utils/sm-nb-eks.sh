#!/bin/bash

echo "==============================================="
echo "  Container tools ......"
echo "==============================================="
ARCH=amd64 # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
PLATFORM=$(uname -s)_$ARCH
if [ ! -f $CUSTOM_DIR/bin/eksctl_$PLATFORM.tar.gz ]; then
  curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" -o $CUSTOM_DIR/bin/eksctl_$PLATFORM.tar.gz
  tar -xzf $CUSTOM_DIR/bin/eksctl_$PLATFORM.tar.gz -C $CUSTOM_DIR/bin
fi
if [ ! -f $CUSTOM_DIR/bin/eksctl_150.tar.gz ]; then
  curl -sL "https://github.com/eksctl-io/eksctl/releases/download/v0.150.0/eksctl_Linux_amd64.tar.gz" -o $CUSTOM_DIR/bin/eksctl_150.tar.gz
  tar -xzf $CUSTOM_DIR/bin/eksctl_150.tar.gz
  mv eksctl $CUSTOM_DIR/bin/eksctl150
fi

if [ ! -f $CUSTOM_DIR/bin/kubectl ]; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  mv kubectl /tmp/
  sudo install -o root -g root -m 0755 /tmp/kubectl $CUSTOM_DIR/bin/kubectl
fi

if [ ! -f $CUSTOM_DIR/bin/get_helm.sh ]; then
  curl -fsSL -o $CUSTOM_DIR/bin/get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod 700 $CUSTOM_DIR/bin/get_helm.sh
fi
$CUSTOM_DIR/bin/get_helm.sh
helm version
helm repo add eks https://aws.github.io/eks-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update
# docker logout public.ecr.aws
helm registry logout public.ecr.aws

if [ ! -f $CUSTOM_DIR/bin/kubectl-karpenter.sh ]; then
  curl -fsSL -o $CUSTOM_DIR/bin/kubectl-karpenter.sh https://raw.githubusercontent.com/TipTopBin/aws-do-eks/main/utils/kubectl-karpenter.sh
  chmod +x $CUSTOM_DIR/bin/kubectl-karpenter.sh
fi

curl -sS https://webinstall.dev/k9s | bash

if [ ! -f $CUSTOM_DIR/bin/kubetail ]; then
  curl -o $CUSTOM_DIR/bin/kubetail https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
  chmod +x $CUSTOM_DIR/bin/kubetail
fi

if [ ! -f $CUSTOM_DIR/bin/kustomize ]; then
  curl -s https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash
  sudo mv -v kustomize $CUSTOM_DIR/bin
fi
kustomize version

if [ ! -f $CUSTOM_DIR/bin/kubie ]; then
  wget https://github.com/sbstp/kubie/releases/latest/download/kubie-linux-amd64 -O $CUSTOM_DIR/bin/kubie
  chmod +x $CUSTOM_DIR/bin/kubie
fi

# Docker Compose
#sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo mkdir -p /usr/local/lib/docker/cli-plugins/
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
# sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o $CUSTOM_DIR/docker-compose
# sudo chmod +x $CUSTOM_DIR/docker-compose
# $CUSTOM_DIR/docker-compose version

# krew
if [ ! -d $CUSTOM_DIR/bin/krew ]; then
  export KREW_ROOT="$CUSTOM_DIR/bin/krew"
  (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
  )

  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  kubectl krew update
  kubectl krew install ctx # kubectx
  kubectl krew install ns # kubens
fi


# # run this script on your eks node
# if [ ! -f $CUSTOM_DIR/bin/eks-log-collector.sh ]; then
#   curl -o $CUSTOM_DIR/bin/eks-log-collector.sh https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/log-collector-script/linux/eks-log-collector.sh 
#   chmod +x $CUSTOM_DIR/bin/eks-log-collector.sh
# fi

# AMI
# export ACCELERATED_AMI=$(aws ssm get-parameter \
#     --name /aws/service/eks/optimized-ami/$EKS_VERSION/amazon-linux-2-gpu/recommended/image_id \
#     --region $AWS_REGION \
#     --query "Parameter.Value" \
#     --output text)


# k8sgpt
if [ ! -f $CUSTOM_DIR/bin/k8sgpt_Linux_x86_64.tar.gz ]; then
  wget -O $CUSTOM_DIR/bin/k8sgpt_Linux_x86_64.tar.gz https://github.com/k8sgpt-ai/k8sgpt/releases/download/v0.3.25/k8sgpt_Linux_x86_64.tar.gz
  tar -xvf $CUSTOM_DIR/bin/k8sgpt_Linux_x86_64.tar.gz -C $CUSTOM_DIR/bin
fi
k8sgpt auth add --backend amazonbedrock --model anthropic.claude-v2
k8sgpt auth list
k8sgpt auth default -p amazonbedrock


echo "==============================================="
echo "  Dev Platform ......"
echo "==============================================="
if [ ! -f $CUSTOM_DIR/bin/devpod ]; then
  curl -L -o $CUSTOM_DIR/bin/devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64" 
  # sudo install -c -m 0755 $CUSTOM_DIR/bin/devpod $CUSTOM_DIR/bin
  chmod 0755 $CUSTOM_DIR/bin/devpod
fi


echo "==============================================="
echo "  Env, Alias and Path ......"
echo "==============================================="

cat >> ~/.bashrc <<EOF
alias nlog=eks-log-collector.sh
alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage" 

source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
alias kk='kubectl-karpenter.sh'
alias kb='k8sgpt'
alias kt=kubetail
alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L karpenter.sh/capacity-type -L node.kubernetes.io/instance-type -L topology.kubernetes.io/zone -L karpenter.sh/nodepool'
alias kgp='kubectl get po -o wide'
alias kga='kubectl get all'
alias kgd='kubectl get deployment -o wide'
alias kgs='kubectl get svc -o wide'
alias ka='kubectl apply -f'
alias ke='kubectl explain'
export dry="--dry-run=client -o yaml"
alias kr='kubectl run \$dry'
alias tk='kt karpenter -n \${KARPENTER_NAMESPACE}'
alias tlbc='kt aws-load-balancer-controller -n kube-system'
alias tebs='kt ebs-csi-controller -n kube-system'
alias tefs='kt efs-csi-controller -n kube-system'

. <(eksctl completion bash)
alias e=eksctl
complete -F __start_eksctl e
alias egn='eksctl get nodegroup --cluster=\${EKS_CLUSTER_NAME}'
alias ess='eksctl scale nodegroup --cluster=\${EKS_CLUSTER_NAME} --name=system --nodes'
alias esn='eksctl scale nodegroup --cluster=\${EKS_CLUSTER_NAME} -n'
alias es0='eksctl scale nodegroup --cluster=\${EKS_CLUSTER_NAME} --nodes=0 --nodes-min=0 -n'

export KREW_ROOT="\$CUSTOM_DIR/bin/krew"
export PATH="\${KREW_ROOT:-\$HOME/.krew}/bin:\$PATH"
EOF

source ~/.bashrc

# if [ -f /home/ec2-user/SageMaker/custom/id_rsa_${EKS_CLUSTER_NAME} ]
# then
#   sudo cp /home/ec2-user/SageMaker/custom/id_rsa_${EKS_CLUSTER_NAME} ~/.ssh/id_rsa
#   chmod 400 ~/.ssh/id_rsa
#   cp /home/ec2-user/SageMaker/custom/id_rsa_pub_${EKS_CLUSTER_NAME} ~/.ssh/id_rsa.pub
#   # ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub
# fi

if [ -f /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_private_key.pem ]
then
  sudo cp /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_private_key.pem ~/.ssh/id_rsa
  sudo cp /home/ec2-user/SageMaker/custom/${EKS_CLUSTER_NAME}_public_key.pem ~/.ssh/id_rsa.pub
  sudo chmod 400 ~/.ssh/id_rsa
  sudo chown -R ec2-user:ec2-user ~/.ssh/
  # ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub
fi


echo "==============================================="
echo "  Resource Metadata ......"
echo "==============================================="
export SAGE_NB_NAME=$(cat /opt/ml/metadata/resource-metadata.json | jq .ResourceName | tr -d '"')
export SAGE_LC_NAME=$(aws sagemaker describe-notebook-instance --notebook-instance-name ${SAGE_NB_NAME} --query NotebookInstanceLifecycleConfigName --output text)
export SAGE_ROLE_ARN=$(aws sagemaker describe-notebook-instance --notebook-instance-name ${SAGE_NB_NAME} --query RoleArn --output text)
export SAGE_ROLE_NAME=$(echo ${SAGE_ROLE_ARN##*/})

echo "export SAGE_NB_NAME=\"$SAGE_NB_NAME\"" >> ~/.bashrc
echo "export SAGE_LC_NAME=\"$SAGE_LC_NAME\"" >> ~/.bashrc
echo "export SAGE_ROLE_NAME=\"$SAGE_ROLE_NAME\"" >> ~/.bashrc
echo "export SAGE_ROLE_ARN=\"$SAGE_ROLE_ARN\"" >> ~/.bashrc


echo "==============================================="
echo "  Load config ......"
echo "==============================================="
if [ ! -z "$EKS_CLUSTER_NAME" ]; then
    # aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}
    /usr/local/bin/aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}
fi


echo "==============================================="
echo "  Local Stable Diffusion ......"
echo "==============================================="
if [ ! -z "$SD_HOME" ]; then
  cd $SD_HOME/sd-webui # WorkingDirectory 注意一定要进入到这个目录
  # TODO check GPU
  nohup $SD_HOME/sd-webui/webui.sh --gradio-auth admin:${SD_PWD} --cors-allow-origins=* --enable-insecure-extension-access --allow-code --medvram --xformers --listen --port 8760 > $SD_HOME/sd.log 2>&1 & # execute asynchronously
fi


##--------------------- Check ENVs -------------------##
source ~/.bashrc

echo -e " EKS_CLUSTER_NAME: $EKS_CLUSTER_NAME\n" \
  "EKS_VERSION: $EKS_VERSION\n" \
  "EKS_MASTER_ARN: ${EKS_MASTER_ARN}\n" \
  "SAGE_NB_NAME: $SAGE_NB_NAME\n" \
  "SAGE_LC_NAME: $SAGE_LC_NAME\n" \
  "SAGE_ROLE_NAME: $SAGE_ROLE_NAME\n" \
  "SAGE_ROLE_ARN: $SAGE_ROLE_ARN\n" \
  "IA_S3_BUCKET: $IA_S3_BUCKET\n" \
  "EFS_FS_NAME: ${EFS_FS_NAME}\n" \
  "EFS_FS_ID: ${EFS_FS_ID}\n" \
  "EFS_PV_DEFAULT: $EFS_PV_DEFAULT\n" \
  "EFS_CLAIM_DEFAULT: $EFS_CLAIM_DEFAULT\n" \
  "EFS_PV_OTEL: $EFS_PV_OTEL\n" \
  "EFS_CLAIM_OTEL: $EFS_CLAIM_OTEL\n" \
  "EMR_VIRTUAL_CLUSTER_NAME: $EMR_VIRTUAL_CLUSTER_NAME\n" \
  "EMR_VIRTUAL_CLUSTER_NS: $EMR_VIRTUAL_CLUSTER_NS\n" \
  "EMR_VIRTUAL_CLUSTER_ID: $EMR_VIRTUAL_CLUSTER_ID\n" \
  "ECR_DATAML_REPO: $ECR_DATAML_REPO\n" \
  "ELB_NLB_ARN: $ELB_NLB_ARN\n"

echo " done"