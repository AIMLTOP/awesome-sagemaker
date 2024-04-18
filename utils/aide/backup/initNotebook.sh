#!/bin/bash


echo "==============================================="
echo "  Env, Alias and Path ......"
echo "==============================================="
# Tag to Env
echo 'export PATH=$PATH:/home/ec2-user/SageMaker/custom:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin' >> ~/.bashrc

cat >> ~/.bashrc <<EOF
alias c=clear
alias z='zip -r ../1.zip .'
alias g=git
alias ll='ls -alh --color=auto'
alias jc=/bin/journalctl
# alias gpa='git pull-all'
alias gpa='git pull-all && git submodule update --remote'
alias gca='git clone-all'
export TERM=xterm-256color
#export TERM=xterm-color
EOF
# echo "alias b='/bin/bash'" | tee -a ~/.bashrc
echo 'export WORKING_DIR=/home/ec2-user/SageMaker/custom' >> ~/.bashrc
echo "alias s5='s5cmd'" | tee -a ~/.bashrc
echo "alias 2s='cd /home/ec2-user/SageMaker'" | tee -a ~/.bashrc
echo "alias 2a='cd /home/ec2-user/SageMaker/awesome'" | tee -a ~/.bashrc
echo "alias 2c='cd /home/ec2-user/SageMaker/custom'" | tee -a ~/.bashrc
# echo "alias 2d='cd /home/ec2-user/SageMaker/awesome/do'" | tee -a ~/.bashrc
echo "alias 2l='cd /home/ec2-user/SageMaker/lab'" | tee -a ~/.bashrc
echo "alias sa='source activate'" | tee -a ~/.bashrc
echo "alias sd='source deactivate'" | tee -a ~/.bashrc
# echo "alias sd='conda deactivate'" | tee -a ~/.bashrc
echo "alias saj='source activate JupyterSystemEnv'" | tee -a ~/.bashrc
echo "alias ca='conda activate'" | tee -a ~/.bashrc
echo "alias cls='conda env list'" | tee -a ~/.bashrc
echo "alias caj='conda activate JupyterSystemEnv'" | tee -a ~/.bashrc
echo "alias rr='sudo systemctl daemon-reload; sudo systemctl restart jupyter-server'" | tee -a ~/.bashrc
source ~/.bashrc