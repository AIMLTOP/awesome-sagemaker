#!/bin/bash
# 调试要小心，如果 JLab 无法打开，可以注释新加的配置
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
    //"overrides": {
    //    "code-font-size": "11px",
    //    "content-font-size1": "13px"
    //}

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
    //"theme": "dark"    
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

#echo "On a new SageMaker terminal, which uses 'sh' by default, type 'bash -l' (without the quotes)"
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


# This nbdime is broken. It crashes with ModuleNotFoundError: jsonschema.protocols.
rm ~/anaconda3/bin/nb{diff,diff-web,dime,merge,merge-web,show} ~/anaconda3/bin/git-nb* || true
hash -r

# Use the good working nbdime
ln -s ~/anaconda3/envs/JupyterSystemEnv/bin/nb{diff,diff-web,dime,merge,merge-web,show} ~/.local/bin/ || true
ln -s ~/anaconda3/envs/JupyterSystemEnv/bin/git-nb* ~/.local/bin/ || true
~/.local/bin/nbdime config-git --enable --global

# pre-commit cache survives reboot (NOTE: can also set $PRE_COMMIT_HOME)
mkdir -p ~/SageMaker/custom/.pre-commit.cache
ln -s ~/SageMaker/custom/.pre-commit.cache ~/.cache/pre-commit || true


# Bash patch
cat << 'EOF' >> ~/.bash_profile

# Workaround: when starting tmux from conda env, deactivate in all tmux sessions.
if [[ ! -z "$TMUX" ]]; then
    for i in $(seq $CONDA_SHLVL); do
        conda deactivate
    done
fi
EOF

# PS1 must preceed conda bash.hook, to correctly display CONDA_PROMPT_MODIFIER
# 路径显示更简洁 (base) [ec2-user@ip-172-16-48-86 custom]$ -> (base) [~/SageMaker/custom] $ 
cp ~/.bashrc{,.ori}
cat << 'EOF' > ~/.bashrc
git_branch() {
   local branch=$(/usr/bin/git branch 2>/dev/null | grep '^*' | colrm 1 2)
   [[ "$branch" == "" ]] && echo "" || echo "($branch) "
}

# All colors are bold
COLOR_GREEN="\[\033[1;32m\]"
COLOR_PURPLE="\[\033[1;35m\]"
COLOR_YELLOW="\[\033[1;33m\]"
COLOR_OFF="\[\033[0m\]"

# Define PS1 before conda bash.hook, to correctly display CONDA_PROMPT_MODIFIER
export PS1="[$COLOR_GREEN\w$COLOR_OFF] $COLOR_PURPLE\$(git_branch)$COLOR_OFF\$ "
EOF

# Original .bashrc content
cat ~/.bashrc.ori >> ~/.bashrc

echo 'To enforce the change to jupyter config: sudo initctl restart jupyter-server --no-wait'
echo 'then refresh your browser'
echo "After this script finishes, reload the Jupyter-Lab page in your browser."
