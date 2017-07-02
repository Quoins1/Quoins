#!/bin/sh
set -ex

# This script will install Quoins globally, create a systemd service for
# it and start the daemon.
#
# It is tested on Debian, but should hopefully work on anything systemd-based.

TARGETBIN="/usr/local/bin/Quoins"
TARGETDATA="/var/local/smly"
TARGETCONF="${TARGETDATA}/Quoins.conf"
TARGETUSER="Quoin"
TARGETGROUP="nogroup"

# ---------------------------

cp src/Quoin "${TARGETBIN}"
chown root:root "${TARGETBIN}"
adduser --system \
    --home "${TARGETDATA}" --no-create-home \
    --disabled-password \
    ${TARGETUSER}
mkdir -p "${TARGETDATA}"
chown -R ${TARGETUSER}:${TARGETGROUP} "${TARGETDATA}"

RPCPASS="$(xxd -ps -l 22 /dev/urandom)"
[ -e "${TARGETCONF}" ] || cat <<EOF > "${TARGETCONF}"
rpcuser=Quoinrpc
rpcpassword=${RPCPASS}
EOF
cat <<EOF > /etc/systemd/system/smly.service
[Unit]
Description=Quoinds
After=network.target

[Service]
ExecStart=${TARGETBIN} -datadir=${TARGETDATA} --server -printtoconsole
User=${TARGETUSER}
Group=${TARGETGROUP}

[Install]
WantedBy=multi-user.target
EOF
systemctl enable Quoin.service
systemctl start Quoin.service
