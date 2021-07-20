#!/bin/sh

set -uexo pipefail

systemctl is-active --quiet certmonger
systemctl is-active --quiet dbus
systemctl is-active --quiet dirsrv@CSPTS-XPI
systemctl is-active --quiet gssproxy
systemctl is-active --quiet httpd
systemctl is-active --quiet ipa-custodia
systemctl is-active --quiet ipa-dnskeysyncd
systemctl is-active --quiet kadmin
systemctl is-active --quiet krb5kdc
systemctl is-active --quiet named-pkcs11
systemctl is-active --quiet oddjobd
systemctl is-active --quiet pki-tomcatd@pki-tomcat
systemctl is-active --quiet sssd
systemctl is-active --quiet systemd-journald
# All services on ipa running/active