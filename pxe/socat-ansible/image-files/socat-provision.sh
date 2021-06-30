#!/bin/bash

read -r REGISTRATION

clientIP=$(echo "$REGISTRATION" | cut -f1 -d' ')
clientType=$(echo "$REGISTRATION" | cut -f2 -d' ')
clientMac=$(echo "$REGISTRATION" | cut -f3 -d' ')

logIP="IP:${clientIP}"
logMac="mac:${clientMac}"
logType="role:${clientType}"
logUsername=''

WD="/root/socat-provisioner/${clientIP}"

rm -rf "${WD}"

if [ "${clientType}" == "infra-dev-laptop" ]
then
    ansible-galaxy collection install community.general
    ansible-galaxy install git+https://gitlab+deploy-token-23364:sE6WnrM8acQy4qaYzYSr@gitlab.com/kraken.io/infra-dev-laptop.git \
    --roles-path "${WD}"
    logUsername="$( (grep -A1 "${clientMac}" "${WD}/infra-dev-laptop/vars/main.yml" | tail -n 1 | tr -d ' ' ; echo username:default) | head -n 1) "
fi

echo "${SSH_PASSWORD}" > "${WD}/passwordfile"

# generate an inventory file
read -r -d '' inventory <<EOF
[client]
${clientIP}

[all:vars]
ansible_ssh_common_args='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
ansible_user=administrator
ansible_ssh_pass=${SSH_PASSWORD}
ansible_become=true
ansible_become_user=root
ansible_become_pass=${SSH_PASSWORD}
ansible_become_method=sudo
EOF

read -r -d '' playbook <<EOF
---
- hosts: client
  remote_user: administrator
  roles:
  - role: ${clientType}
EOF

echo "${inventory}" > "${WD}/hosts"
echo "${playbook}" > "${WD}/playbook.yml"

ansible-playbook -e 'host_key_checking=False' "${WD}/playbook.yml" -i "${WD}/hosts" --vault-password-file "${WD}/passwordfile" && \
echo "$(date) -- ${logType} ${logIP} ${logMac} ${logUsername}was successfully provisioned." >> /var/log/provisioning-report.log
rm -rf ${WD}