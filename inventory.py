#!/usr/bin/env python3
import json
import os
import sys

def main():
    ip = os.environ.get('TF_OUTPUT_instance_ip', '')
    #server_ip = os.environ.get('TF_OUTPUT_server_ip', '')

    #if not server_ip:
    #    sys.stderr.write("ERROR: TF_OUTPUT_server_ip environment variable is not set\n")
    #    sys.exit(1)

    inventory = {
        "pihole_server_group": {
            "hosts": ["pihole-server"],
        },
        "_meta": {
            "hostvars": {
                "pihole-server": {
                    "ansible_host": ip,
#                    "ansible_host": os.environ.get("INSTANCE_IP")
                    "ansible_user": "ansible",
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

#    print(json.dumps(inventory, indent=2))
    print(json.dumps(inventory))

if __name__ == '__main__':
    if len(sys.argv) == 2 and sys.argv[1] == '--list':
        main()
    elif len(sys.argv) == 2 and sys.argv[1] == '--host':
        print(json.dumps({}))
    else:
        main()
