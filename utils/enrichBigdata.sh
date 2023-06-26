#!/bin/bash


echo "==============================================="
echo "  Install emr-on-eks-custom-image ......"
echo "==============================================="
wget -O /tmp/amazon-emr-on-eks-custom-image-cli-linux.zip https://github.com/awslabs/amazon-emr-on-eks-custom-image-cli/releases/download/v1.03/amazon-emr-on-eks-custom-image-cli-linux-v1.03.zip
sudo mkdir -p /opt/emr-on-eks-custom-image
unzip /tmp/amazon-emr-on-eks-custom-image-cli-linux.zip -d /opt/emr-on-eks-custom-image
sudo /opt/emr-on-eks-custom-image/installation
emr-on-eks-custom-image --version
cat >> ~/.bashrc <<EOF
alias eec=emr-on-eks-custom-image
EOF
source ~/.bashrc
eec --version


echo "==============================================="
echo "  Install flink ......"
echo "==============================================="
wget https://archive.apache.org/dist/flink/flink-1.15.3/flink-1.15.3-bin-scala_2.12.tgz -O /tmp/flink-1.15.3.tgz
sudo tar xzvf /tmp/flink-1.15.3.tgz -C /opt
sudo chown -R ec2-user /opt/flink-1.15.3
cat >> ~/.bashrc <<EOF
export PATH="/opt/flink-1.15.3/bin:$PATH"
EOF
source ~/.bashrc
flink -v


echo "==============================================="
echo "  mwaa-local-runner ......"
echo "==============================================="
# https://dev.to/aws/getting-mwaa-local-runner-up-on-aws-cloud9-1nhd