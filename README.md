# unbound-minfwd

This repository contains files to build a minimal docker image that can be used to run
unbound as a forwarding resolver. The configuration is fairly simple and contains just what
is needed for standard DNS and DNS over TLS based forwarding.

## Building the image

The following will build and tag the image as `unbound-minfwd:latest`:

```
make docker
```

## Testing image locally

The makefile also contains a couple targets to test the image locally.

`make run-local-gdns` will start a container instance up configured to listen on
port 5300, and forward to Google public resolvers using standard DNS.

`make run-local-cdns` will start a container instance up configured to listen on
port 5300, and forward to Cloudflare public resolvers using DNS over TLS.
