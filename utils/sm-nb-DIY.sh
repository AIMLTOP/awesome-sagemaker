#!/bin/bash

source ~/.bashrc

echo "==============================================="
echo "  S3 Bucket ......"
echo "==============================================="
if [ ! -f $CUSTOM_DIR/bin/mount-s3.rpm ]; then
  wget -O $CUSTOM_DIR/bin/mount-s3.rpm https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm
fi
sudo yum install -y $CUSTOM_DIR/bin/mount-s3.rpm
echo "alias ms3='mount-s3'" | tee -a ~/.bashrc
# mount-s3 [OPTIONS] <BUCKET_NAME> <DIRECTORY>
if [ ! -z "$IA_S3_BUCKET" ]; then
    mkdir -p /home/ec2-user/SageMaker/s3/${IA_S3_BUCKET}
    mount-s3 ${IA_S3_BUCKET} /home/ec2-user/SageMaker/s3/${IA_S3_BUCKET}
fi



echo "==============================================="
echo "  EFS ......"
echo "==============================================="
if [ ! -z "$EFS_FS_ID" ]; then
  mkdir -p /home/ec2-user/SageMaker/efs
  # sudo mount -t efs -o tls ${EFS_FS_ID}:/ /efs # Using the EFS mount helper
  echo "${EFS_FS_ID}.efs.${AWS_REGION}.amazonaws.com:/ /home/ec2-user/SageMaker/efs efs _netdev,tls 0 0" | sudo tee -a /etc/fstab  
fi
sudo mount -a
sudo chown -hR +1000:+1000 /home/ec2-user/SageMaker/efs*
#sudo chmod 777 /home/ec2-user/SageMaker/efs*

