# docker run -it --rm --env-file env.list theraapster/cloudflare-ddns
FROM bash:4.4

COPY dns.sh /

RUN apk add --no-cache jq curl bind-tools

CMD ["bash", "/dns.sh"]