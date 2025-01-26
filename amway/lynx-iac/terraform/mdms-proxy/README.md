# MDMS Proxy infrastructure

This infrastructure is intented for keeping everything up while backend servers are down for maintenance or update. The proxy is based on NGINX, configured as a caching proxy, returning stalled responses when backend is down.

## Testing

I tested the infrastructure by simply obtaining tokens via API. Below you may find request I issued, with hidden secrets. It may be useful to obtain full API schema from someone from the team to test it.

### TS3

> POST /rest/oauth2/v1/token HTTP/1.1
> Host: api-ts3.amwayglobal.com
> Content-Type: application/x-www-form-urlencoded
> Cache-Control: no-cache
>
> client_id=fs8yqe4xtth2hbusmtcykkeh&client_secret=##########&grant_type=client_credentials&scope=aboNum%3D7001130959+salesPlanAff%3D420+partyId%3D0

### QA

> POST /rest/oauth2/v1/token HTTP/1.1
> Host: api-qa-proxy.hybris.eia.amway.net:1235
> Content-Type: application/x-www-form-urlencoded
> Cache-Control: no-cache
>
> client_id=a5bhkregtw6furt6xcdnny4x&client_secret=##########&grant_type=client_credentials&scope=aboNum%3D7001159290+salesPlanAff%3D420+partyId%3D0

### QA3

> POST /rest/oauth2/v1/token HTTP/1.1
> Host: api-qa3-proxy.hybris.eia.amway.net:1235
> Content-Type: application/x-www-form-urlencoded
> Cache-Control: no-cache
>
> client_id=xrjq6m5t9rpfhhk92yfahdhw&client_secret=##########&grant_type=client_credentials