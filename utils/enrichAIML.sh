#!/bin/bash

mkdir -p ~/environment/aiml && cd ~/environment/aiml
cd ~/environment/aiml
# cd /home/ec2-user/
yum update -y


echo "==============================================="
echo "  Dev tools & Anaconda3 ......"
echo "==============================================="
yum -y groupinstall "Development tools"
yum -y install openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel
# wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
# bash Anaconda3-2021.05-Linux-x86_64.sh -b -p /home/ec2-user/anaconda3
wget -O /tmp/Anaconda3-2021.05-Linux-x86_64.sh https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
bash /tmp/Anaconda3-2021.05-Linux-x86_64.sh -b -p /home/ec2-user/environment/anaconda3
source ~/.bashrc


echo "==============================================="
echo "  Jupyter ......"
echo "==============================================="
# https://studio.us-east-1.prod.workshops.aws/workshops/public/9cc3f765-77c6-4255-99a1-8e98ff483347
# touch /home/ec2-user/jupyterpassword.py
# echo "from notebook.auth import passwd" | cat >> /home/ec2-user/jupyterpassword.py
# echo "import os" | cat >> jupyterpassword.py
# echo "print(passwd('Awslabs'))" | cat >> /home/ec2-user/jupyterpassword.py
cat > /home/ec2-user/environment/aiml/jupyterpassword.py <<EOF
from notebook.auth import passwd
import random, string
generated_string = ''.join(random.SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(17))
f = open("/home/ec2-user/environment/aiml/jupyterpassword.txt", "w")
f.write(generated_string)
f.close()
print(passwd(generated_string))
EOF

# echo "eval \"\$(/home/ec2-user/anaconda3/bin/conda shell.bash hook)\"" | cat >> /home/ec2-user/jupytersetup.sh
# echo "conda init" | cat >> /home/ec2-user/jupytersetup.sh
# echo "jupyter notebook --generate-config" | cat >> /home/ec2-user/jupytersetup.sh

# a="encrypted_pwd=\$(python3 /home/ec2-user/jupyterpassword.py)"
# echo $a | cat >> /home/ec2-user/jupytersetup.sh
# b="sed -i 's/c = get_config()/#c = get_config()/' /root/.jupyter/jupyter_notebook_config.py"
# echo $b | cat >> /home/ec2-user/jupytersetup.sh
# c="sed -i \"1 i\\c.NotebookApp.password=\\'\$encrypted_pwd\'\" /root/.jupyter/jupyter_notebook_config.py"
# echo $c | cat >> /home/ec2-user/jupytersetup.sh
# d="sed -i '1 i\\c.NotebookApp.port=8888' /root/.jupyter/jupyter_notebook_config.py"
# echo $d | cat >> /home/ec2-user/jupytersetup.sh
# e="sed -i '1 i\\c.NotebookApp.open_browser=False' /root/.jupyter/jupyter_notebook_config.py"
# echo $e | cat >> /home/ec2-user/jupytersetup.sh
# f="sed -i \"1 i\\c.NotebookApp.ip='*'\" /root/.jupyter/jupyter_notebook_config.py"
# echo $f | cat >> /home/ec2-user/jupytersetup.sh

echo "eval \"\$(/home/ec2-user/environment/anaconda3/bin/conda shell.bash hook)\"" | cat >> /home/ec2-user/environment/aiml/jupytersetup.sh
echo "conda init" | cat >> /home/ec2-user/environment/aiml/jupytersetup.sh
echo "jupyter notebook --generate-config" | cat >> /home/ec2-user/environment/aiml/jupytersetup.sh

a="encrypted_pwd=\$(python3 /home/ec2-user/environment/aiml/jupyterpassword.py)"
echo $a | cat >> /home/ec2-user/environment/aiml/jupytersetup.sh
b="sed -i 's/c = get_config()/#c = get_config()/' /root/.jupyter/jupyter_notebook_config.py"
echo $b | cat >> /home/ec2-user/environment/aiml/jupytersetup.sh
c="sed -i \"1 i\\c.NotebookApp.password=\\'\$encrypted_pwd\'\" /root/.jupyter/jupyter_notebook_config.py"
echo $c | cat >> /home/ec2-user/environment/aiml/jupytersetup.sh
d="sed -i '1 i\\c.NotebookApp.port=8888' /root/.jupyter/jupyter_notebook_config.py"
echo $d | cat >> /home/ec2-user/environment/aiml/jupytersetup.sh
e="sed -i '1 i\\c.NotebookApp.open_browser=False' /root/.jupyter/jupyter_notebook_config.py"
echo $e | cat >> /home/ec2-user/environment/aiml/jupytersetup.sh
f="sed -i \"1 i\\c.NotebookApp.ip='*'\" /root/.jupyter/jupyter_notebook_config.py"
echo $f | cat >> /home/ec2-user/environment/aiml/jupytersetup.sh

# setup in root 
sudo su
chmod +x /home/ec2-user/environment/aiml/jupytersetup.sh
/home/ec2-user/environment/aiml/jupytersetup.sh
source ~/.bashrc
# conda -V
exit

# manage in ec2-user
echo "export PATH=/home/ec2-user/environment/anaconda3/bin:\$PATH" | sudo tee -a ~/.bashrc
source ~/.bashrc
mkdir /home/ec2-user/environment/notebooks

## start up example (run as root)
# sudo su
# cd /home/ec2-user/environment/notebooks
# jupyter notebook --allow-root


# echo "==============================================="
# echo "  Stable Diffusion ......"
# echo "==============================================="
# https://github.com/awslabs/stable-diffusion-aws-extension/blob/main/docs/Environment-Preconfiguration.md
wget https://raw.githubusercontent.com/awslabs/stable-diffusion-aws-extension/main/install.sh -O ~/environment/aiml/install-sd.sh
sh ~/environment/aiml/install-sd.sh
# CPU 如果遇到 pip 找不到错误，尝试更新到 Python 3.8+，然后重启
~/environment/aiml/stable-diffusion-webui/webui.sh --enable-insecure-extension-access --skip-torch-cuda-test --no-half --listen
# ~/environment/aiml/stable-diffusion-webui/webui.sh --enable-insecure-extension-access --skip-torch-cuda-test --port 8080 --no-half --listen
