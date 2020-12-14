#!/bin/sh

rm -rf /etc/turnserver.conf

echo "user=$DEFAULT_TURN_USER"
echo "pass=$DEFAULT_TURN_PASSWORD"
echo "realm=$DEFAULT_TURN_REALM"

internalIp="$(ip a | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -m 1 -v '127.0.0.1')"
externalIp="$(curl api.ipify.org)"

echo "Internal IP: $internalIp"
echo "External IP: $externalIp"

(
cat <<EOF
listening-port=3478
tls-listening-port=5349
listening-ip=$internalIp
relay-ip=$internalIp
external-ip=$externalIp

min-port=49152
max-port=65535

realm=$REALM
server-name=$REALM
lt-cred-mech
# use real-valid certificate/privatekey files
cert=/etc/ssl/turn_server_cert.pem
pkey=/etc/ssl/turn_server_pkey.pem

# no-stdout-log
syslog
user=$DEFAULT_TURN_USER:$DEFAULT_TURN_PASSWORD
realm=$DEFAULT_TURN_REALM

cli-ip=127.0.0.1
cli-port=5766
cli-password=qwerty
EOF
) > /etc/turnserver.conf

turnserver

echo "TURN server running"
