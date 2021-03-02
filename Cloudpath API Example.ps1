#Credentials
$APIKey = "YOURKEYGOESHERE"
$user = "YOURUSERNAMEGOESHERE"
$pass = "YOURPASSWORDGOESHERE"

#Build the authentication payload
$auth = @{}
$auth.Add('userName',$user)
$auth.Add('password',$pass)

#The base domain for your Cloudpath instance, in this case the SaaS service at eu1 in AWS
$CloudpathBaseDomain = "eu1.cloudpath.net"

#Get a new JSON Web Token
$JWTpath = "https://$CloudpathBaseDomain/admin/apiv2/$APIKey/token"
$JWTOutput = Invoke-RestMethod -Method POST -Uri $JWTpath -ContentType 'application/json' -Body ($auth | ConvertTo-Json)

$JWT = @{}
$JWT.Add('Authorization',$JWTOutput.token)

#Fetch the DPSKs in that pool, note that you can change the page size
$DPSKPoolGUID = "AccountDpskPool-GUIDGOESHERE"
$path = "https://$CloudpathBaseDomain/admin/apiv2/$APIKey/dpskPools/$DPSKPoolGUID/dpsks/?pageSize=10000"
$DPSKs = Invoke-RestMethod -Method Get -Uri $path -ContentType 'application/json' -Headers $JWT

#Output the response in a grid view
$DPSKs.contents | Out-GridView

#Output just a single response
$DPSKs.contents[0]

#Editing a DPSK account
$DPSKPoolGUID = "AccountDpskPool-GUIDGOESHERE"
$DPSKGUID = "AccountDpsk-GUIDGOESHERE"

#Get just the single DPSK
$path = "https://$CloudpathBaseDomain/admin/apiv2/$APIKey/dpskPools/$DPSKPoolGUID/dpsks/$DPSKGUID"
$getresult = Invoke-RestMethod -Method Get -Uri $path -ContentType 'application/json' -Headers $JWT

#Based on the response build a payload which will change the expirationDateTime
$putnewdpsk = @{}
$putnewdpsk.Add('guid',$getresult.guid)
$putnewdpsk.Add('name',$getresult.name)
$putnewdpsk.Add('passphrase',$getresult.passphrase)
$putnewdpsk.Add('status',$getresult.status)
$putnewdpsk.Add('ssidList',$getresult.ssidList)
$putnewdpsk.Add('expirationDateTime','2021-03-06T00:00-07:00[Europe/London]')

#Push that payload to the DPSK
Invoke-RestMethod -Method Put -Uri $path -ContentType 'application/json' -Headers $JWT -Body ($putnewdpsk | ConvertTo-Json)
