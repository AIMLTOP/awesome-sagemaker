#!/bin/bash

set -e

sudo -u ec2-user -i <<'EOF'
unset SUDO_UID
WORKING_DIR=/home/ec2-user/SageMaker/custom/tf26-p38
source "$WORKING_DIR/miniconda/bin/activate"
for env in $WORKING_DIR/miniconda/envs/*; do
    BASENAME=$(basename "$env")
    source activate "$BASENAME"
    python -m ipykernel install --user --name "$BASENAME" --display-name "Custom ($BASENAME)"
done
EOF

echo "Config SSH ..."
export LOCAL_PUBLIC_KEY="xxxxx"
cat >> /home/ec2-user/.ssh/authorized_keys <<EOF
${LOCAL_PUBLIC_KEY}
EOF

echo "Restarting the Jupyter server ..."
sudo systemctl restart jupyter-server