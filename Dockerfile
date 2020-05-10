FROM mcr.microsoft.com/powershell

COPY dns.ps1 /

RUN apt-get update && apt-get install -y \
	dnsutils \
	--no-install-recommends

CMD ["pwsh", "/dns.ps1"]