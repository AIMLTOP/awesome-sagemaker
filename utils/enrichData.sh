#!/bin/bash

echo "==============================================="
echo "  Prepare the data folder ......"
echo "==============================================="
mkdir -p ~/environment/do


echo "==============================================="
echo "  Data on Amazon EKS (DoEKS) ......"
echo "==============================================="
git clone https://github.com/CLOUDCNTOP/data-on-eks.git ~/environment/do/data-on-eks


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
echo "  Kafka ......"
echo "==============================================="
wget https://archive.apache.org/dist/kafka/2.8.1/kafka_2.12-2.8.1.tgz -O /tmp/kafka_2.12-2.8.1.tgz
tar -xzf /tmp/kafka_2.12-2.8.1.tgz -C ~/environment/do/
sudo chown -R ec2-user ~/environment/do
cat >> ~/.bashrc <<EOF
export PATH="~/environment/do/kafka_2.12-2.8.1/bin:$PATH"
EOF
source ~/.bashrc
# ln -s kafka_2.12-2.8.1 kafka


echo "==============================================="
echo "  Install Cruise Control ......"
echo "==============================================="
git clone https://github.com/linkedin/cruise-control.git ~/environment/do/cruise-control && cd ~/environment/do/cruise-control/
./gradlew jar copyDependantLibs
mkdir logs; touch logs/kafka-cruise-control.out
# export MSK_ARN=`aws kafka list-clusters|grep ClusterArn|cut -d ':' -f 2-|cut -d ',' -f 1 | sed -e 's/\"//g'`
export MSK_ARN=$(aws kafka list-clusters --output json | jq -r .ClusterInfoList[].ClusterArn)
# export MSK_BROKERS=`aws kafka get-bootstrap-brokers --cluster-arn $MSK_ARN|grep BootstrapBrokerString|grep 9092| cut -d ':' -f 2- | sed -e 's/\"//g' | sed -e 's/,$//'`
export MSK_BROKERS=$(aws kafka get-bootstrap-brokers --cluster-arn $MSK_ARN --output json | jq -r .BootstrapBrokerString)
# export MSK_ZOOKEEPER=`aws kafka describe-cluster --cluster-arn $MSK_ARN|grep ZookeeperConnectString|grep -v Tls|cut -d ':' -f 2-|sed 's/,$//g'|sed -e 's/\"//g'`
export MSK_ZOOKEEPER=$(aws kafka describe-cluster --cluster-arn $MSK_ARN|grep ZookeeperConnectString|grep -v Tls|cut -d ':' -f 2-|sed 's/,$//g'|sed -e 's/\"//g')
echo "export MSK_ARN=\"${MSK_ARN}\"" | tee -a ~/.bashrc
echo "export MSK_BROKERS=\"${MSK_BROKERS}\"" | tee -a ~/.bashrc
echo "export MSK_ZOOKEEPER=\"${MSK_ZOOKEEPER}\"" >> ~/.bashrc
source ~/.bashrc

# sed -i "s/localhost:9092/${MSK_BROKERS}/g" config/cruisecontrol.properties
# sed -i "s/localhost:2181/${MSK_ZOOKEEPER}/g" config/cruisecontrol.properties
# sed -i "s/webserver.http.port=9090/webserver.http.port=8080/g" config/cruisecontrol.properties 
# sed -i "s/capacity.config.file=config\/capacityJBOD.json/capacity.config.file=.\/config\/capacityCores.json/g" config/cruisecontrol.properties
# sudo chmod -R 777 .
# # sed -i "s/com.linkedin.kafka.cruisecontrol.monitor.sampling.CruiseControlMetricsReporterSampler/com.linkedin.kafka.cruisecontrol.monitor.sampling.prometheus.PrometheusMetricSampler/g" config/cruisecontrol.properties
# # echo "prometheus.server.endpoint=localhost:9090" >> config/cruisecontrol.properties
# update capacityCores.json
# # start 
# cd ~/environment/do/cruise-control/
# ./kafka-cruise-control-start.sh -daemon config/cruisecontrol.properties
wget https://github.com/linkedin/cruise-control-ui/releases/download/v0.3.4/cruise-control-ui-0.3.4.tar.gz  -O /tmp/cruise-control-ui-0.3.4.tar.gz
sudo tar xzvf /tmp/cruise-control-ui-0.3.4.tar.gz -C ~/environment/do/cruise-control/
sudo chown -R ec2-user ~/environment/do/cruise-control/


echo "==============================================="
echo "  mwaa-local-runner ......"
echo "==============================================="
# https://dev.to/aws/getting-mwaa-local-runner-up-on-aws-cloud9-1nhd


echo "==============================================="
echo "  postgresql ......"
echo "==============================================="
# https://catalog.workshops.aws/performance-tuning/en-US/30-environment
sudo amazon-linux-extras install -y python3.8 postgresql14
sudo yum install -y jq postgresql-contrib


echo "==============================================="
echo "  mysql ......"
echo "==============================================="
# wget -c https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell-8.0.32-linux-glibc2.12-x86-64bit.tar.gz
# tar -xf mysql-shell-8.0.32-linux-glibc2.12-x86-64bit.tar.gz
# mysqlsh
