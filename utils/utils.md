

## Python

```shell
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

## /tmp

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