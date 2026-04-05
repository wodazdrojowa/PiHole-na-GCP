#!/bin/bash
cat > /mnt/workspace/source/inventory.py << EOF
[pihole-server]

#pihole-server ansible_host=${TF_OUTPUT_server_ip} ansible_user=ansible ansible_ssh_private_key_file=/mnt/workspace/id_ed25519
pihole-server ansible_host=os.environ.get("INSTANCE_IP") ansible_user=ansiblegenerateinventorysh

[pihole-server:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
