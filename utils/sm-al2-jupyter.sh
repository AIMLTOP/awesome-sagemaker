#!/bin/bash

source ~/.bashrc

echo "Configue Jupyterlab"
mkdir -p ~/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/
cat > ~/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/notification.jupyterlab-settings <<EoL
{
    // Notifications
    // @jupyterlab/apputils-extension:notification
    // Notifications settings.
    // *******************************************

    // Fetch official Jupyter news
    // Whether to fetch news from Jupyter news feed. If `true`, it will make a request to a website.
    "fetchNews": "false"
}
EoL

cat > ~/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings <<EoL
{
    // Theme
    // @jupyterlab/apputils-extension:themes
    // Theme manager settings.
    // *************************************

    // Selected Theme
    // Application-level visual styling theme
    "theme": "JupyterLab Dark"
}
EoL

mkdir -p ~/.jupyter/lab/user-settings/@jupyterlab/terminal-extension/
cat > ~/.jupyter/lab/user-settings/@jupyterlab/terminal-extension/plugin.jupyterlab-settings <<EoL
{
    // Terminal
    // @jupyterlab/terminal-extension:plugin
    // Terminal settings.
    // *************************************

    // Font size
    // The font size used to render text.
    "fontSize": 15,
    "lineHeight": 1.3
}
EoL


# https://docs.aws.amazon.com/sagemaker/latest/dg/docker-containers-troubleshooting.html
mkdir -p ~/.sagemaker
cat > ~/.sagemaker/config.yaml <<EOF
local:
  container_root: /home/ec2-user/SageMaker/tmp
EOF
