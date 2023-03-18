#!/bin/bash

set -e

fwd_cfg_path=/usr/local/etc/unbound/unbound.conf.d/forward.conf
drop_cfg_path=/usr/local/etc/unbound/unbound.conf.d/drop.conf
server_cfg_path=/usr/local/etc/unbound/unbound.conf.d/server.conf

# Do any additional configuration here before we start the process.

# If FORWARD_TLS is set, enable forward-ssl-upstream in the forwarding
# configuration.
if [[ ! -z "$FORWARD_TLS" ]]; then
	echo '    forward-ssl-upstream: yes' >> $fwd_cfg_path
fi

# Add any configured forwarding addresses.
if [[ ! -z "$FORWARD_ADDRS" ]]; then
	for i in $FORWARD_ADDRS; do
		echo "    forward-addr: $i" >> $fwd_cfg_path
	done
fi

# Configure any zones we want to drop queries for.
if [[ ! -z "$DROP_ZONES" ]]; then
	for i in $DROP_ZONES; do
		echo "    local-zone: \"$i\" refuse" >> $drop_cfg_path
	done
fi

# Set tcp-reuse-timeout if specified.
if [[ ! -z "$TCP_REUSE_TIMEOUT" ]]; then
	echo "    tcp-reuse-timeout: $TCP_REUSE_TIMEOUT" >> $server_cfg_path
	cat $server_cfg_path
fi

/usr/local/sbin/unbound-anchor -a /var/lib/unbound/root.key -4 || true

if [[ -z "$@" ]]; then
	exec /usr/local/sbin/unbound-harness
else
	exec "$@"
fi
