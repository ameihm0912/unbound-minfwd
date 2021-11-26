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

## Image details

Dynamic container configuration is minimal, and provided through environment variables. You
will need to provide at the least a value for `FORWARD_ADDRS`. See `Makefile` for examples
provided in the test targets.

The unbound service within the container will listen on port 5300; configure docker forwarding
to this port as desired.

#### FORWARD_ADDRS

Set to a space delimited list of upstream resolvers to forward to. These will be rendered
into the unbound configuration as `forward-addr` options.

#### FORWARD_TLS

Set this environment variable to enable TLS upstream forwarding if DNS over TLS is desired.
