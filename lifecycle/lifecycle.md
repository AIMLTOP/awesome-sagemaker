

## Backup 

Create:
```shell
# Chose Kite or jupyterlab-lsp, Not Both
# Kite Engine
#bash -c "$(wget -q -O - https://linux.kite.com/dls/linux/current)"
#yes "" | bash -c "$(wget -q -O - https://linux.kite.com/dls/linux/current)"

# https://github.com/kiteco/jupyterlab-kite
#pip install "jupyterlab-kite>=2.0.2"

# jupyterlab_tabnine https://www.tabnine.com/install/jupyterlab
#pip3 install jupyterlab_tabnine # 不好用

# sudo systemctl restart jupyter-server
# source deactivate
```

Start:
```shell
# kite
# with systemd, run systemctl --user start kite-autostart
# without systemd, run /home/ec2-user/.local/share/kite/kited
# or launch it using the Applications Menu
```