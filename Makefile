all:

docker:
	docker build -t unbound-minfwd:latest .

docker-builder:
	docker build --target builder -t unbound-minfwd:builder .

# Test with Google public DNS resolvers
run-local-gdns:
	docker run -ti --rm \
		-p 5300:5300/tcp \
		-p 5300:5300/udp \
		-e FORWARD_ADDRS='8.8.8.8 8.8.4.4' \
		unbound-minfwd:latest

# Test with Cloudflare public DNS over TLS resolvers
run-local-cdns:
	docker run -ti --rm \
		-p 5300:5300/tcp \
		-p 5300:5300/udp \
		-e FORWARD_TLS=1 \
		-e FORWARD_ADDRS='1.1.1.1@853#cloudflare-dns.com 1.0.0.1@853#cloudflare-dns.com' \
		unbound-minfwd:latest

.PHONY: docker docker-builder run-local-gdns run-local-cdns
