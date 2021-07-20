#!/bin/sh

set -euxo pipefail

tftp 127.0.0.1 -c get pxelinux.cfg/default /tftptest.txt
diff /tftptest.txt /tftpboot/pxelinux.cfg/default -q