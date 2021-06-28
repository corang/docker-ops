#!/bin/bash
set -euxo pipefail

echo "Writing script file"
cat >/bin/firstboot.sh <<EOL
#!/bin/bash
clientIP=\$(hostname -I | cut -d ' ' -f 1)
clientMac=\$(ifconfig -a | grep ether | head -1 | tr -s ' ' | cut -d ' ' -f 3)
echo "\${clientIP} infra-dev-laptop \${clientMac}" > "/dev/tcp/139.241.255.5/54321"
logger "provisioner: \${clientIP} infra-dev-laptop sent to server"
systemctl disable runonce
rm -f /etc/systemd/runonce.service
systemctl set-default graphical.target
EOL

echo "Making script executable"
chmod +x /bin/firstboot.sh

echo "Writing service file"
cat >/etc/systemd/system/runonce.service <<EOL
[Unit]
Description=Runonce Provisioner
After=network-online.target

[Service]
Type=simple
User=root
ExecStart=/bin/firstboot.sh
Restart=no

[Install]
WantedBy=multi-user.target
EOL

echo "Enabling runonce service"
systemctl enable runonce

echo "Finished"
sleep 15s