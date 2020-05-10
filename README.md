# Docker CloudFlare DDNS (Powershell)
This is a container that updates a CloudFlare DNS record based on the current external IP address.

## Usage

Quick Setup:

```shell
docker run \
  -e ENV_CLOUDFLARE_TOKEN=xxxxxxx \
  -e ENV_CLOUDFLARE_DOMAIN=example.com \
  -e ENV_CLOUDFLARE_HOSTNAME=subdomain \
  --rm \
  theraapster/cloudflare-ddns
```

Optionally, create an environment variable file and pass that instead:

```shell
docker run -it --rm --env-file env.list theraapster/cloudflare-ddns
```
