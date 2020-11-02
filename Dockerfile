FROM mcr.microsoft.com/powershell

RUN apt-get update && apt-get install -y \
	dnsutils \
	--no-install-recommends

COPY dns.ps1 /

CMD ["pwsh", "/dns.ps1"]