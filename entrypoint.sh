#!/bin/bash

set -e

fwd_cfg_path=/usr/local/etc/unbound/unbound.conf.d/forward.conf

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

/usr/local/sbin/unbound-anchor -a /var/lib/unbound/root.key -4 || true

if [[ -z "$@" ]]; then
	/usr/local/sbin/unbound
else
	exec "$@"
fi
