#!/bin/bash

source ~/.bashrc

JUPYTER_CONFIG_ROOT=~/.jupyter/lab/user-settings/\@jupyterlab

echo "Install Extensions ... "
source /home/ec2-user/anaconda3/bin/activate JupyterSystemEnv
pip install amazon-codewhisperer-jupyterlab-ext
jupyter server extension enable amazon_codewhisperer_jupyterlab_ext
source /home/ec2-user/anaconda3/bin/deactivate


echo "Configue Jupyterlab"
mkdir -p $JUPYTER_CONFIG_ROOT/apputils-extension/
# mkdir -p ~/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/
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

# cat > ~/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings <<EoL
cat > $JUPYTER_CONFIG_ROOT/apputils-extension/themes.jupyterlab-settings <<EoL
{
    // Theme
    // @jupyterlab/apputils-extension:themes
    // Theme manager settings.
    // *************************************

    // Selected Theme
    // Application-level visual styling theme
    "theme": "JupyterLab Dark"

    // Theme CSS Overrides
    // Override theme CSS variables by setting key-value pairs here
    "overrides": {
        "code-font-size": "11px",
        "content-font-size1": "13px"
    }

    // Scrollbar Theming
    // Enable/disable styling of the application scrollbars
    // "theme-scrollbars": false
}
EoL


mkdir -p $JUPYTER_CONFIG_ROOT/terminal-extension/
cat > $JUPYTER_CONFIG_ROOT/terminal-extension/plugin.jupyterlab-settings <<EoL
{
    // Terminal
    // @jupyterlab/terminal-extension:plugin
    // Terminal settings.
    // *************************************

    // Font size
    // The font size used to render text.
    "fontSize": 15,
    "lineHeight": 1.3

    // Theme
    // The theme for the terminal.
    "theme": "dark"    
}
EoL

# mkdir -p $JUPYTER_CONFIG_ROOT/fileeditor-extension/
# cat << EOF > $JUPYTER_CONFIG_ROOT/fileeditor-extension/plugin.jupyterlab-settings
# {
#     "editorConfig": {
#         "rulers": [80, 100],
#         "codeFolding": true,
#         "lineNumbers": true,
#         "lineWrap": "off"
#     }
# }
# EOF

# mkdir -p $JUPYTER_CONFIG_ROOT/codemirror-extension/
# cat << EOF > $JUPYTER_CONFIG_ROOT/codemirror-extension/plugin.jupyterlab-settings
# {
#     // CodeMirror
#     // @jupyterlab/codemirror-extension:plugin
#     // Text editor settings for all CodeMirror editors.
#     // ************************************************

#     "defaultConfig": {
#         "codeFolding": true,
#         "highlightActiveLine": true,
#         "highlightTrailingWhitespace": true,
#         "rulers": [
#             80,
#             100
#         ]
#     }
# }
# EOF

# mkdir -p $JUPYTER_CONFIG_ROOT/notebook-extension/
# cat << EOF > $JUPYTER_CONFIG_ROOT/notebook-extension/tracker.jupyterlab-settings
# {
#     // Notebook
#     // @jupyterlab/notebook-extension:tracker
#     // Notebook settings.
#     // **************************************

#     // Code Cell Configuration
#     // The configuration for all code cells; it will override the CodeMirror default configuration.
#     "codeCellConfig": {
#         "lineNumbers": true,
#         "lineWrap": true
#     },

#     // Markdown Cell Configuration
#     // The configuration for all markdown cells; it will override the CodeMirror default configuration.
#     "markdownCellConfig": {
#         "lineNumbers": true,
#         "lineWrap": true
#     },

#     // Raw Cell Configuration
#     // The configuration for all raw cells; it will override the CodeMirror default configuration.
#     "rawCellConfig": {
#         "lineNumbers": true,
#         "lineWrap": true
#     }
# }
# EOF

# cat << EOF > $JUPYTER_CONFIG_ROOT/notebook-extension/tracker.jupyterlab-settings
# {
#     "codeCellConfig": {
#         "rulers": [80, 100],
#         "codeFolding": true,
#         "lineNumbers": true,
#         "lineWrap": "off"
#     },
#     "markdownCellConfig": {
#         "rulers": [80, 100],
#         "codeFolding": true,
#         "lineNumbers": true,
#         "lineWrap": "off"
#     },
#     "rawCellConfig": {
#         "rulers": [80, 100],
#         "lineNumbers": true,
#         "lineWrap": "off"
#     }
# }
# EOF

try_append() {
    local key="$1"
    local value="$2"
    local msg="$3"
    local cfg="$4"

    HAS_KEY=$(grep "^$key" ~/.jupyter/jupyter_${cfg}_config.py | wc -l)

    if [[ $HAS_KEY > 0 ]]; then
        echo "Skip adding $key because it already exists in $HOME/.jupyter/jupyter_${cfg}_config.py"
        return 1
    fi

    echo "$key = $value" >> ~/.jupyter/jupyter_${cfg}_config.py
    echo $msg
}


touch ~/.jupyter/jupyter_server_config.py

try_append \
    c.NotebookApp.terminado_settings \
    "{'shell_command': ['/bin/bash', '-l']}" \
    "Changed shell to /bin/bash" \
    notebook

try_append \
    c.ServerApp.terminado_settings \
    "{'shell_command': ['/bin/bash', '-l']}" \
    "Changed shell to /bin/bash" \
    server

try_append \
    c.EnvironmentKernelSpecManager.conda_env_dirs \
    "['/home/ec2-user/anaconda3/envs', '/home/ec2-user/SageMaker/envs']" \
    "Register additional prefixes for conda environments" \
    notebook

try_append \
    c.EnvironmentKernelSpecManager.conda_env_dirs \
    "['/home/ec2-user/anaconda3/envs', '/home/ec2-user/SageMaker/envs']" \
    "Register additional prefixes for conda environments" \
    server

echo 'To enforce the change to jupyter config: sudo initctl restart jupyter-server --no-wait'
echo 'then refresh your browser'
echo "After this script finishes, reload the Jupyter-Lab page in your browser."
