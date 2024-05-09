<div align="center">
  <a href="https://aws.amazon.com/sagemaker/">
  <img width="250" height="250"  src="img/awesome-sagemaker-intro.svg" alt="SageMaker"></a>
</div>
<h1 align="center">
	AWSome SageMaker
</h1>
<div align="center">
  <a href="https://github.com/sindresorhus/awesome">
  <img src="https://awesome.re/badge.svg" alt="Awesome">
  </a>
  <img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fsofianhamiti%2Fawesome-sagemaker&count_bg=%23198ED5&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false" alt="hits">
</div>

> A curated list of awesome references for Amazon SageMaker.

:ledger: The curated list consists of the following sections.  

* [**Getting Started**](./getting_started.md)  - Start here if you are setting up Sagemaker (including studio)
  - [Introduction](./getting_started.md#introduction)
  - [Developer Experience](./getting_started.md#developer-experience)
  - [Architecture Best Practices](./getting_started.md#architecture-best-practices) 
  - [ML Platform Setup](./getting_started.md#ml-platform-setup)

* [**Data Preparation**](./data_preparation.md) - Understand the options to prepare data for machine learning  
  - [Data Processing](./data_preparation.md#data-processing)  
  - [Large Scale Data Processing](./data_preparation.md#large-scale-data-processing)   
  - [Data Labeling](./data_preparation.md#data-labeling)

* [**Building ML Models**](building_ml_models.md) - Contains resources for running notebooks and training models
  - [SDKs and Infrastructure-as-code](./building_ml_models.md#sdks--infrastructure-as-code)
  - [Training](./building_ml_models.md#training)

* [**Deploying ML Models**](deploying_ml_models.md) - Different ways to deploy models and their best practices
  - [Inference](./deploying_ml_models.md#inference)
  - [Hardware Acceleration](./deploying_ml_models.md#hardware-acceleration)
  - [Edge Deployments](./deploying_ml_models.md#edge-deployments)
  - [Debugging](./deploying_ml_models.md#debugging)  

* [**MLOps**](mlops.md) - Machine Learning Operations
  - [MLOps Foundations](./mlops.md#mlops-foundations)
  - [SageMaker Pipelines](./mlops.md#sagemaker-pipelines)
  - [Third-Party](./mlops.md#using-third-party) 
  - [Experiment Tracking and Model Registry](./mlops.md#experiment-tracking--model-registry)
  - [Data Versioning and Feature store](./mlops.md#data-versioning--feature-store)
  - [Model Monitoring](./mlops.md#model-monitoring)

* [**Low Code / No Code ML**](low_code_no_code_ml.md) - Low code approach to date preparation and model building
  - [Low Code - No Code](./low_code_no_code_ml.md#low-code-no-code)
  - [AutoML](./low_code_no_code_ml.md#automl)
  - [Data Wrangler](./low_code_no_code_ml.md#data-wrangler)

* [**Generative AI**](generative_ai.md) - deploy and use generative AI models
  - [Train and deploy Foundational Models](./generative_ai.md#train-and-deploy-foundational-models)
  - [prompt engineering and few shot/zero shot learning](./generative_ai.md#prompt-engineering-and-few-shotzero-shot-learning)
  - [Fine tune Foundational Models](https://github.com/aws-samples/awesome-sagemaker/blob/main/generative_ai.md#fine-tune-foundational-models)
  - [Building Generative AI applications](./generative_ai.md#building-generative-ai-applications)

* [**ML Domains**](ml_domains.md) - Deep dive on domains such as NLP, CV, Tabular, Audio and Reinforcement Learning
  - [Responsible AI](./ml_domains.md#responsible-ai)
  - [ML Governance](./ml_domains.md#ml-governance) ([Model Management](./ml_domains.md#model-management), [Security](./ml_domains.md#security), [Cost Tracking & Control](./ml_domains.md#cost-tracking--control))
  - [Computer Vision](./ml_domains.md#computer-vision)
  - [Natural Language Processing](./ml_domains.md#natural-language-processing)
  - [R](./ml_domains.md#r)
  - [Audio](./ml_domains.md#audio)

* [**Learning Sagemaker**](learning_sagemaker.md) - Trainings, certifications, books and community
  - [Certification](learning_sagemaker.md#certification)
  - [MOOCs](learning_sagemaker.md#moocs)
  - [Digital & Classroom](learning_sagemaker.md#digital--classroom)
  - [Tutorials](learning_sagemaker.md#tutorials)
  - [Community](learning_sagemaker.md#community)
  - [Books](learning_sagemaker.md#books)
  - [News](learning_sagemaker.md#news)

## :handshake: Contributing

If you'd like to open an issue, for having a defunct link removed or corrected, or you want to propose interesting content and share it into the list through a pull request, please read our [contributing guidelines](./CONTRIBUTING.md).
The pull request will be evaluated by the project owners and incorporated into the list. Please ensure that you add the link to the appropriate sub-page and the link points to unique content that is not already covered by one of the other links.
We're extremely excited to receive contributions from the community, and we're still working on the best mechanism to take in examples from external sources.




## Node

```
v18 got error

#node: /lib64/libm.so.6: version `GLIBC_2.27' not found (required by node)
#node: /lib64/libc.so.6: version `GLIBC_2.28' not found (required by node)
```


```shell
## yum
# DEPRECATION way
# curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
# sudo yum install nodejs gcc-c++ make -y
# node -v
```

## Python

```shell
# https://github.com/pyenv/pyenv-installer
# curl https://pyenv.run | bash
# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"

sudo ln -s /usr/local/bin/pip3 /usr/bin
which python3.8
sudo yum update -y
cat >> ~/.bashrc <<EOF
alias python='/usr/bin/python3.8'
alias pip3='/usr/bin/pip3.8'
EOF
source ~/.bashrc
Install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py; python get-pip.py; rm -f get-pip.py
sudo mv ~/.local/bin/pip3 ~/.local/bin/pip3_backup
sudo mv /usr/bin/pip /usr/bin/pip_backup
sudo mv /usr/bin/pip3 /usr/bin/pip3_backup
sudo mv /usr/bin/python3 /usr/bin/python3_backup
# alternatives [options] --install link name path priority [--slave link name path]... [--initscript service]
sudo alternatives --install /usr/bin/python python /usr/bin/python3.8 1
sudo alternatives --install /usr/bin/pip pip /usr/bin/pip3.8 1
sudo ln -s /usr/bin/python3.8 /usr/bin/python3
sudo ln -s /usr/bin/pip3.8 /usr/bin/pip3
compile install
sudo yum install -y gcc openssl-devel bzip2-devel libffi-devel zlib-devel make tar gzip ca-certificates procps net-tools which vim wget libgomp htop jq bind-utils bc pciutils
sudo cd /opt && \
    wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz && \
    tar xzf Python-3.8.12.tgz && \
    cd Python-3.8.12 && ./configure --enable-optimizations && \
    make altinstall
sudo alternatives --install /usr/bin/python python /usr/local/bin/python3.8 1; alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.8 1
```


## JQ

替换 "，可以考虑直接在提取的时候用  `jq -r`

## tmp

- https://unix.stackexchange.com/questions/71622/what-are-correct-permissions-for-tmp-i-unintentionally-set-it-all-public-recu

```shell
chmod 1777 /tmp
find /tmp \
     -mindepth 1 \
     -name '.*-unix' -exec chmod 1777 {} + -prune -o \
     -exec chmod go-rwx {} +
```

## KK

- https://earthly.dev/blog/jq-select/


```shell
export KUBECTL_KARPENTER="eval \"\$(kubectl get nodes -o json | jq '.items|=sort_by(.metadata.creationTimestamp) | .items[]' | jq -r '[ \"printf\", \"%-50s %-19s %-19s %-2s %-2s %-6s %-15s %s %s\\n\", .metadata.name, (.spec.providerID | split(\"/\")[4]), (.metadata.creationTimestamp | sub(\"Z\";\"\") | sub(\"T\";\" \")), (if ((.status.conditions | map(select(.status == \"True\"))[0].type) == \"Ready\") then \"✔\" else \"?\" end), (.metadata.labels.\"topology.kubernetes.io/zone\" | split(\"-\")[2]), (.metadata.labels.\"node.kubernetes.io/instance-type\" | sub(\"arge\";\"\")), (if .metadata.labels.\"karpenter.k8s.aws/instance-network-bandwidth\" then .metadata.labels.\"karpenter.k8s.aws/instance-cpu\"+\"核\"+(.metadata.labels.\"karpenter.k8s.aws/instance-memory\" | tonumber/1024 | tostring+\"G\")+(.metadata.labels.\"karpenter.k8s.aws/instance-network-bandwidth\" | tonumber/1000 | tostring+\"Gbps\") else .status.capacity.cpu+\"核\"+(.status.capacity.memory | sub(\"Ki\";\"\") | tonumber/1024/1024 | floor+1 | tostring+\"G\")+\"\" end),  (if .metadata.labels.\"karpenter.sh/capacity-type\" == \"on-demand\" or .metadata.labels.\"eks.amazonaws.com/capacityType\" == \"ON_DEMAND\" then \"按需\" else \"SPOT\" end), (.metadata.labels.\"karpenter.sh/provisioner-name\" // \" *系统节点-勿删*\") ] | @sh')\""


export KUBECTL_KARPENTER="eval \"\$(kubectl get nodes -o json | jq '.items|=sort_by(.metadata.creationTimestamp) | .items[]' | jq -r '[ \"printf\", \"%-50s %-19s %-19s %-2s %-2s %-6s %-15s %s %s\\n\", .metadata.name, (.spec.providerID | split(\"/\")[4]), (.metadata.creationTimestamp | sub(\"Z\";\"\") | sub(\"T\";\" \")), (if (.status.conditions[] | select(.status == \"True\") | .type) == \"Ready\" then \"✔\" else \"?\" end), (.metadata.labels.\"topology.kubernetes.io/zone\" | split(\"-\")[2]), (.metadata.labels.\"node.kubernetes.io/instance-type\" | sub(\"arge\";\"\")), (if .metadata.labels.\"karpenter.k8s.aws/instance-network-bandwidth\" then .metadata.labels.\"karpenter.k8s.aws/instance-cpu\"+\"核\"+(.metadata.labels.\"karpenter.k8s.aws/instance-memory\" | tonumber/1024 | tostring+\"G\")+(.metadata.labels.\"karpenter.k8s.aws/instance-network-bandwidth\" | tonumber/1000 | tostring+\"Gbps\") else .status.capacity.cpu+\"核\"+(.status.capacity.memory | sub(\"Ki\";\"\") | tonumber/1024/1024 | floor+1 | tostring+\"G\")+\"\" end),  (if .metadata.labels.\"karpenter.sh/capacity-type\" == \"on-demand\" or .metadata.labels.\"eks.amazonaws.com/capacityType\" == \"ON_DEMAND\" then \"按需\" else \"SPOT\" end), (.metadata.labels.\"karpenter.sh/provisioner-name\" // \" *系统节点-勿删*\") ] | @sh')\""

export KUBECTL_KARPENTER="eval \"\$(kubectl get nodes -o json | jq '.items[]' | jq -r '[ \"printf\", \"%-45s %s %-12s %-11s %-5s %-6s %-6s %-10s %s\\n\", .metadata.name, (.spec.providerID | split(\"/\")[4]), .metadata.labels.\"topology.kubernetes.io/zone\", .metadata.labels.\"node.kubernetes.io/instance-type\", .metadata.labels.\"karpenter.k8s.aws/instance-cpu\", .metadata.labels.\"karpenter.k8s.aws/instance-memory\", .metadata.labels.\"karpenter.k8s.aws/instance-network-bandwidth\", (.metadata.labels.\"karpenter.sh/capacity-type\"), .metadata.labels.\"karpenter.sh/provisioner-name\" ] | @sh')\""

kubectl get nodes -o json | jq -jr '.items[] | .metadata.name, "\t", .spec.providerID, "\n"'

kubectl get nodes -o json | jq -jr '.items[] | .metadata.name, "\t", (.spec.providerID | split("/")[4]), .metadata.labels."karpenter.sh/capacity-type", .metadata.labels.node.kubernetes.io/instance-type,"\n"'

kubectl get nodes -o json | jq -jr '.items[] | .metadata.name, "\t", (.spec.providerID | split("/")[4]), "\t", .metadata.labels."node.kubernetes.io/instance-type", "\t", .metadata.labels."karpenter.k8s.aws/instance-network-bandwidth", "\t",  .metadata.labels."topology.kubernetes.io/zone", "\t", (.metadata.labels."karpenter.sh/capacity-type"=="spot" |  // .metadata.labels."eks.amazonaws.com/capacityType"), "\t", (.metadata.labels."karpenter.sh/provisioner-name" // "\t" ), "\t", "\n"'


eval "$(kubectl get nodes -o json | jq '.items[]' | jq -r '[ "printf", "%-45s %-22s %-15s %-10s %10s %-10s %-12s %-12s %s\\n", .metadata.name, (.spec.providerID | split("/")[4]), .metadata.labels."node.kubernetes.io/instance-type", .metadata.labels."karpenter.k8s.aws/instance-cpu", .metadata.labels."karpenter.k8s.aws/instance-memory", .metadata.labels."karpenter.k8s.aws/instance-network-bandwidth", .metadata.labels."topology.kubernetes.io/zone", (.metadata.labels."karpenter.sh/capacity-type"), .metadata.labels."karpenter.sh/provisioner-name" ] | @sh')"

eval "$(kubectl get nodes -o json | jq '.items[]' | jq -r '[ "printf", "%-45s %s %-12s %-11s %-5s %-6s %-6s %-10s %s\\n", .metadata.name, (.spec.providerID | split("/")[4]), .metadata.labels."topology.kubernetes.io/zone", .metadata.labels."node.kubernetes.io/instance-type", .metadata.labels."karpenter.k8s.aws/instance-cpu", .metadata.labels."karpenter.k8s.aws/instance-memory", .metadata.labels."karpenter.k8s.aws/instance-network-bandwidth", (.metadata.labels."karpenter.sh/capacity-type"), .metadata.labels."karpenter.sh/provisioner-name" ] | @sh')"


kubectl get nodes -o json | jq -jr '.items[] | to_entries[] | [.metadata.name, .metadata.labels."karpenter.sh/capacity-type", .metadata.labels."node.kubernetes.io/instance-type", .metadata.labels."topology.kubernetes.io/zone" ] | @tsv'  

kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'


kubectl get nodes -o json | jq -jr --tab '.items[] | .metadata.name, "\t" , map(.spec.providerID | split("/")[0]) , "\n"'

 --sort-by=.metadata.creationTimestamp
```

## ENV

```
EKS_PUB_SUBNET_01=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${EKS_VPC_ID}" "Name=availability-zone, Values=${AWS_REGION}a" --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' --output text)
```

## Bash in Bash

Simple Example
```shell
sudo bash -c "cat << EOF > /usr/local/bin/b
#!/bin/bash
/bin/bash
EOF"
sudo chmod +x /usr/local/bin/b
```


Complex Example
```shell
sudo bash -c "cat > /usr/local/bin/rc <<EOF
#!/bin/bash
echo \"alias c='clear'\" | tee -a ~/.bashrc
echo \"alias b='/bin/bash'\" | tee -a ~/.bashrc
echo \"alias cs='cd /home/ec2-user/SageMaker'\" | tee -a ~/.bashrc
echo \"alias cls='conda env list'\" | tee -a ~/.bashrc
echo \"alias sa='source activate JupyterSystemEnv'\" | tee -a ~/.bashrc
echo \"alias sd='source deactivate'\" | tee -a ~/.bashrc
echo \"alias rr='sudo systemctl daemon-reload; sudo systemctl restart jupyter-server'\" | tee -a ~/.bashrc

echo export GOPATH=\\\$(go env GOPATH) | tee -a ~/.bashrc
echo export PATH=\\\$PATH:\\\$GOPATH/bin | tee -a ~/.bashrc

echo \"export PYENV_ROOT=\\\$HOME/.pyenv\" | tee -a ~/.bashrc
echo \"export PATH=\\\$HOME/.pyenv/bin\:\\\$PATH\" | tee -a ~/.bashrc
eval \"\\\$(\\\$HOME/.pyenv/bin/pyenv init -)\"

unset SUDO_UID
WORKING_DIR=/home/ec2-user/SageMaker/custom
source \"\\\$WORKING_DIR/miniconda/bin/activate\"

for env in \\\$WORKING_DIR/miniconda/envs/*; do
    BASENAME=\\\$(basename \"\\\$env\")
    conda activate \"\\\$BASENAME\"
    python -m ipykernel install --user --name \"\\\$BASENAME\"
done

IDLE_TIME=10800
CONDA_PYTHON_DIR=\\\$(source /home/ec2-user/anaconda3/bin/activate /home/ec2-user/anaconda3/envs/JupyterSystemEnv && which python)
if \\\$CONDA_PYTHON_DIR -c \"import boto3\" 2>/dev/null; then
    PYTHON_DIR=\\\$CONDA_PYTHON_DIR
elif /usr/bin/python -c \"import boto3\" 2>/dev/null; then
    PYTHON_DIR='/usr/bin/python'
else
    echo \"No boto3 found in Python or Python3. Exiting...\"
    exit 1
fi
echo \"Starting the SageMaker autostop script in cron\"
(crontab -l 2>/dev/null; echo \"*/5 * * * * \\\$PYTHON_DIR /home/ec2-user/SageMaker/custom/autostop.py --time \\\$IDLE_TIME --ignore-connections >> /var/log/jupyter.log\") | crontab -
EOF"
sudo chmod +x /usr/local/bin/rc
rc
source ~/.bashrc
```

不加 display-name，避免重复
```shell
python -m ipykernel install --user --name \"\\\$BASENAME\" --display-name \"Custom (\\\$BASENAME)\"
```



## Backup

```shell
sudo python3 -m pip install awscurl

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
```


Resize:
```shell
#!/bin/bash

# Specify the desired volume size in GiB as a command-line argument. If not specified, default to 20 GiB.
SIZE=${1:-20}

# Get the ID of the environment host Amazon EC2 instance.
INSTANCEID=$(curl http://169.254.169.254/latest/meta-data//instance-id)

# Get the ID of the Amazon EBS volume associated with the instance.
VOLUMEID=$(aws ec2 describe-instances \
  --instance-id $INSTANCEID \
  --query "Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId" \
  --output text)

# Resize the EBS volume.
aws ec2 modify-volume --volume-id $VOLUMEID --size $SIZE

# Wait for the resize to finish.
while [ \
  "$(aws ec2 describe-volumes-modifications \
    --volume-id $VOLUMEID \
    --filters Name=modification-state,Values="optimizing","completed" \
    --query "length(VolumesModifications)"\
    --output text)" != "1" ]; do
sleep 1
done

if [ $(readlink -f /dev/xvda) = "/dev/xvda" ]
then
  # Rewrite the partition table so that the partition takes up all the space that it can.
  sudo growpart /dev/xvda 1

  # Expand the size of the file system.
  sudo resize2fs /dev/xvda1

else
  # Rewrite the partition table so that the partition takes up all the space that it can.
  sudo growpart /dev/nvme0n1 1

  # Expand the size of the file system.
  sudo xfs_growfs -d /
fi
```