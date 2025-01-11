FROM ubuntu:focal AS base

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y libexpat-dev libevent-dev libssl-dev \
		ca-certificates

FROM base AS builder

WORKDIR /root
RUN apt-get install -y curl build-essential
RUN curl -OL https://nlnetlabs.nl/downloads/unbound/unbound-1.22.0.tar.gz && \
	tar -zxf unbound-1.22.0.tar.gz && \
	cd unbound-1.22.0 && \
	./configure --with-libexpat=/usr --with-libevent --with-ssl && \
	make && make install

COPY src/unbound-harness /root/unbound-harness
RUN cd unbound-harness && make clean && make

FROM base AS final
COPY --from=builder /usr/local/sbin/unbound /usr/local/sbin/unbound
COPY --from=builder /usr/local/sbin/unbound-anchor /usr/local/sbin/unbound-anchor
COPY --from=builder /usr/local/lib/libunbound.so.8.1.30 /usr/local/lib/libunbound.so.8.1.30
COPY --from=builder /root/unbound-harness/unbound-harness /usr/local/sbin/unbound-harness
RUN mkdir -p /usr/local/etc/unbound/unbound.conf.d \
	/var/lib/unbound && \
	useradd -s /usr/sbin/nologin unbound && \
	chown -R unbound:unbound /var/lib/unbound && \
	ldconfig
COPY etc/unbound.conf /usr/local/etc/unbound/unbound.conf
COPY etc/unbound.conf.d/* /usr/local/etc/unbound/unbound.conf.d/
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
