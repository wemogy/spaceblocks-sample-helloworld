const express = require('express')
const app = express()
const port = 3000
import { PermissionsClient, CreateTenantRequest, Members, MembersDictionary } from '@spaceblocks/permissions-server';

const client = new PermissionsClient(
  '<YOUR_PERMISSIONS_URL>',
  '<YOUR_API_KEY>',
  {
    clientId: '<YOUR_CLIENT_ID>',
    clientSecret: '<YOUR_CLIENT_SECRET>'
  });

await client.tenantApi.patchTenantMembers(
    "default",
    new Members([
      { "alice": ["internal"] },
      { "linda": ["tax-accountant"] }
    ]));

app.get('/GetWeatherForecast/', async (req, res) => {

  const permissions = await client.tenantApi.getTenantPermissions(
    "default",
    "city",
    req.query.city,
    req.query.user);

  const canGetCurrentForecast = permissions["city"].Contains("get-current-forecast");


  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
