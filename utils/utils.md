

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