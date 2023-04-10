#!/bin/bash

#set -e
set -eux

systemctl restart jupyter-server

sudo chmod +x /home/ec2-user/SageMaker/custom/*.sh
sudo chown ec2-user:ec2-user /home/ec2-user/SageMaker/custom/ -R