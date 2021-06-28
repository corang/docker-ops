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
elif [ "${clientType}" == "infra-dev-test" ]
then
    ansible-galaxy install git+https://gitlab+deploy-token-113589:kxdGpqsPQ283t4xLsXwA@gitlab.com/kraken.io/infra-dev-test.git \
    --roles-path "${WD}"
    logUsername="$( (grep -A1 "${clientMac}" "${WD}/infra-dev-test/vars/main.yml" | tail -n 1 | tr -d ' ' ; echo username:default) | head -n 1) "
elif [ "${clientType}" == "concourse-server" ]
then
    ansible-galaxy install git+https://gitlab+deploy-token-187222:XDCzQqNgoTUwBsj_zU1y@gitlab.com/kraken.io/concourse-server.git \
    --roles-path "${WD}"
elif [ "${clientType}" == "acas-server" ]
then
    ansible-galaxy install git+https://gitlab+deploy-token-41930:vsa5ZeorbhkffzVVP46d@gitlab.com/kraken.io/acas-server.git \
    --roles-path "${WD}"
elif [ "${clientType}" == "gitlab-server" ]
then
    ansible-galaxy install git+https://gitlab+deploy-token-145681:yyyD1BTdySjzLrLybLxA@gitlab.com/kraken.io/gitlab-server.git \
    --roles-path "${WD}"
elif [ "${clientType}" == "pxe-server" ]
then
    ansible-galaxy install git+https://gitlab+deploy-token-42923:tWTtaQaM_3_9uyCxhMg1@gitlab.com/kraken.io/pxe-server.git \
    --roles-path "${WD}"
elif [ "${clientType}" == "atlas-sandbox" ]
then
    ansible-galaxy install git+https://gitlab+deploy-token-60554:yaNvkRkQfcjKu6gTYEcf@gitlab.com/kraken.io/atlas-sandbox.git \
    --roles-path "${WD}"
elif [ "${clientType}" == "ipa-server" ]
then
    ansible-galaxy install git+https://gitlab+deploy-token-84295:X8BBgkCzgJR8KdezZJNe@gitlab.com/kraken.io/ipa-server.git \
    --roles-path "${WD}"
elif [ "${clientType}" == "designer-macbook" ]
then
    ansible-galaxy install git+https://gitlab+deploy-token-94303:uUH3t_vuL8vHATuZsnfP@gitlab.com/kraken.io/designer-macbook.git \
    --roles-path "${WD}"
fi

echo "{{ password }}" > "${WD}/passwordfile"
if [ "${clientType}" == "designer-macbook" ]
then
# generate an inventory file
read -r -d '' inventory <<EOF
[client]
${clientIP}

[all:vars]
ansible_ssh_common_args='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
ansible_user=administrator
ansible_ssh_pass={{ password }}
ansible_sudo_pass={{ password }}
EOF

read -r -d '' playbook <<EOF
---
- hosts: client
  remote_user: admin
  roles:
  - role: ${clientType}
EOF
else
# generate an inventory file
read -r -d '' inventory <<EOF
[client]
${clientIP}

[all:vars]
ansible_ssh_common_args='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
ansible_user=administrator
ansible_ssh_pass={{ password }}
ansible_become=true
ansible_become_user=root
ansible_become_pass={{ password }}
ansible_become_method=sudo
EOF

read -r -d '' playbook <<EOF
---
- hosts: client
  remote_user: administrator
  roles:
  - role: ${clientType}
EOF
fi
echo "${inventory}" > "${WD}/hosts"
echo "${playbook}" > "${WD}/playbook.yml"

ansible-playbook -e 'host_key_checking=False' "${WD}/playbook.yml" -i "${WD}/hosts" --vault-password-file "${WD}/passwordfile" && \
echo "$(date) -- ${logType} ${logIP} ${logMac} ${logUsername}was successfully provisioned." >> /var/log/provisioning-report.log
rm -rf ${WD}