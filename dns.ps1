$CLOUDFLARE_TOKEN = $env:ENV_CLOUDFLARE_TOKEN
$CLOUDFLARE_DOMAIN = $env:ENV_CLOUDFLARE_DOMAIN
$CLOUDFLARE_HOSTNAME = $env:ENV_CLOUDFLARE_HOSTNAME

$CLOUDFLARE_API_ENDPOINT = 'https://api.cloudflare.com/client/v4'

$Dig = 'dig +short myip.opendns.com `@resolver1.opendns.com'

$ExternalIp = Invoke-Expression $Dig

$Headers = @{
    'Authorization' = "Bearer $CLOUDFLARE_TOKEN"
}

$URI_Zone = "$CLOUDFLARE_API_ENDPOINT/zones?name=$CLOUDFLARE_DOMAIN"

Write-Host "Getting zone id for $($CLOUDFLARE_DOMAIN): $URI_Zone"

$ZoneId = (Invoke-RestMethod -Uri $URI_Zone -ContentType 'application/json' -Headers $Headers).result.id

$URI_DNS = "$CLOUDFLARE_API_ENDPOINT/zones/$ZoneId/dns_records?type=A&name=$CLOUDFLARE_HOSTNAME.$CLOUDFLARE_DOMAIN"

Write-Host "Getting DNS data for $($CLOUDFLARE_HOSTNAME).$($CLOUDFLARE_DOMAIN): $URI_DNS"

$DNSData = (Invoke-RestMethod -Uri $URI_DNS -ContentType 'application/json' -Headers $Headers).result

if ($ExternalIp -ne $DNSData.content) {
    #New external IP address, time to try to update
    Write-Host "External IP address has changed, updating DNS"
    try {
        $Body = @{
            'type' = 'A'
            'name' = "$CLOUDFLARE_HOSTNAME.$CLOUDFLARE_DOMAIN"
            'content' = $ExternalIp
            'ttl' = '1'
        }

        $URI_Update = "$CLOUDFLARE_API_ENDPOINT/zones/$ZoneId/dns_records/$($DNSData.id)"

        Write-Host "Updating DNS: $URI_Update"

        $Result = (Invoke-RestMethod -Uri $URI_Update `
                                    -Method Put `
                                    -ContentType 'application/json' `
                                    -Headers $Headers `
                                    -Body $($Body | ConvertTo-Json)).result
        
        if ($Result.content -eq $ExternalIp) {
            Write-Host "External IP successfully updated"
        }
        else {
            Write-Host "DNS was not successfully updated"
        }
    }
    catch {
        Write-Host "Unable to update DNS: $($error[0].ErrorDetails.Message)"
        throw
    }
}
else {
    Write-Host "DNS is up to date, no need to update"
}