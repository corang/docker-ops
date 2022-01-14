#!/bin/bash
set -euxo pipefail

echo "Writing script file"
cat >/bin/firstboot.sh <<EOL
#!/bin/bash
sleep 10s
tput -T screen reset > /dev/tty1
echo -e "\n Starting pre-provision process" > /dev/tty1
mkdir -p /tmp
echo -e "\n Downloading NetworkManager" > /dev/tty1
curl http://192.168.2.4/packages/networkManager.tar.gz --output /tmp/nm.tar.gz
mkdir -p /tmp/packages
tar -xvzf /tmp/nm.tar.gz -C /tmp/packages
echo -e "\n Installing NetworkManager" > /dev/tty1
dpkg -i /tmp/packages/*.deb
echo -e "\n Configuring Netplan" > /dev/tty1
sed -i '2 a \ \ renderer: NetworkManager' /etc/netplan/00-installer-config.yaml
netplan apply
echo -e "\n Restarting NetworkManager to apply network config changes" > /dev/tty1
systemctl restart NetworkManager
echo -e "\n Configuring NetworkManager" > /dev/tty1
nmcli connection add type ethernet autoconnect yes ifname eth0 con-name "Office Net" 802-1x.eap "md5" 802-1x.identity admin 802-1x.password TODO
nmcli connection add type ethernet autoconnect yes ifname eth0 con-name "Home Net"
nmcli connection up "Office Net" ifname eth0
sleep 15s
echo -e "\n Updating all packages and installing net-tools dependency" > /dev/tty1
apt update
apt upgrade -y --fix-broken > /dev/tty1
apt install net-tools -y
echo -e "\n Starting provisioning process" > /dev/tty1
clientIP=\$(hostname -I | cut -d ' ' -f 1)
clientMac=\$(ifconfig -a | grep ether | head -1 | tr -s ' ' | cut -d ' ' -f 3)
echo -e "\${clientIP} infra-dev-laptop \${clientMac}" > "/dev/tcp/192.168.1.5/54321"
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

echo "Configuring netplan to use eth0"
sed -i '4s/.*/    eth0:/' /etc/netplan/00-installer-config.yaml

echo "Finished"
sleep 15s