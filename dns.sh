# Set environment variables to their appropriate values
CLOUDFLARE_TOKEN="${ENV_CLOUDFLARE_TOKEN}"
CLOUDFLARE_EMAIL="${ENV_CLOUDFLARE_EMAIL}"
CLOUDFLARE_DOMAIN="${ENV_CLOUDFLARE_DOMAIN}"
CLOUDFLARE_HOSTNAME="${ENV_CLOUDFLARE_HOSTNAME}"

# This shouldn't need to be updated often
CLOUDFLARE_API_ENDPOINT='https://api.cloudflare.com/client/v4/'

###############################
# Don't touch from here down
###############################
EXTIP=$(dig +short myip.opendns.com @resolver1.opendns.com)

# Get ZONE_ID from domain
ZONE_ID=$(curl -s -X GET "$CLOUDFLARE_API_ENDPOINT/zones?name=$CLOUDFLARE_DOMAIN" \
-H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
-H "X-Auth-Key: $CLOUDFLARE_TOKEN" \
-H "Content-Type: application/json" \
| jq --raw-output '.result[].id')

# Get current DNS record for host name and inject external IP
DNS_DATA=$(curl -s -X GET "$CLOUDFLARE_API_ENDPOINT/zones/$ZONE_ID/dns_records?type=A&name=$CLOUDFLARE_HOSTNAME.$CLOUDFLARE_DOMAIN" \
-H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
-H "X-Auth-Key: $CLOUDFLARE_TOKEN" \
-H "Content-Type: application/json" \
| jq --arg ip $EXTIP '.result[] | .content = $ip')

#echo "DNS Data:"
#echo $DNS_DATA | jq '.'

DNS_ID=$(echo $DNS_DATA | jq --raw-output '.id')

#echo "DNS_ID:"
#echo $DNS_ID

# Update DNS record
SUCCESS=$(curl -s -X PUT "$CLOUDFLARE_API_ENDPOINT/zones/$ZONE_ID/dns_records/$DNS_ID" \
-H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
-H "X-Auth-Key: $CLOUDFLARE_TOKEN" \
-H "Content-Type: application/json" \
--data "$DNS_DATA" \
| jq --raw-output '.success')

#if [ SUCCESS ]
#then
#  echo "$CLOUDFLARE_HOSTNAME.$CLOUDFLARE_DOMAIN updated to $EXTIP"
#else
#  echo "$CLOUDFLARE_HOSTNAME.$CLOUDFLARE_DOMAIN failed to update"
#fi