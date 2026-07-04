#!/usr/bin/env python3
import json
import os
import sys

def main():
    ip = os.environ.get('INSTANCE_IP', '')

    inventory = {
        "pihole_server_group": {
            "hosts": ["pihole-server"],
        },
        "_meta": {
            "hostvars": {
                "pihole-server": {
                    "ansible_host": ip,
                    "ansible_user": os.environ.get('SSH_USER', 'ansible'),
                    "ansible_ssh_private_key_file": "/mnt/workspace/id_ed25519",
                    "ansible_python_interpreter": "/usr/bin/python3",
                    "ansible_ssh_common_args": "-o StrictHostKeyChecking=no"
                }
            }
        },
        "all": {
            "hosts": ["pihole-server"]
        }
    }

    print(json.dumps(inventory))

if __name__ == '__main__':
    if len(sys.argv) == 2 and sys.argv[1] == '--list':
        main()
    elif len(sys.argv) == 2 and sys.argv[1] == '--host':
        print(json.dumps({}))
    else:
        main()
