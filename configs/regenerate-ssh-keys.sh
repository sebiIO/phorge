#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

SSH_KEYS_DIR="/var/repo/.sshkeys"

if [[ ! -d "$SSH_KEYS_DIR" ]]; then
    echo '==> Regenerating SSH host keys...'
    mkdir -p "$SSH_KEYS_DIR"
    ssh-keygen -t dsa -f "${SSH_KEYS_DIR}/ssh_host_dsa_key" -N "" > /dev/null 2>&1
    ssh-keygen -t rsa -f "${SSH_KEYS_DIR}/ssh_host_rsa_key" -N "" > /dev/null 2>&1
    ssh-keygen -t ecdsa -f "${SSH_KEYS_DIR}/ssh_host_ecdsa_key" -N "" > /dev/null 2>&1
    ssh-keygen -t ed25519 -f "${SSH_KEYS_DIR}/ssh_host_ed25519_key" -N "" > /dev/null 2>&1
fi
rm -f /etc/ssh/ssh_host_*
cp -rp "${SSH_KEYS_DIR}"/. /etc/ssh/
