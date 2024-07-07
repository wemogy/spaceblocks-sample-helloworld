const PermissionsClient = require('@spaceblocks/permissions-server').PermissionsClient;
const express = require('express')

const client = new PermissionsClient(
  '<YOUR_PERMISSIONS_URL>',
  '<YOUR_API_KEY>',
  {
    clientId: '<YOUR_CLIENT_ID>',
    clientSecret: '<YOUR_CLIENT_SECRET>'
  });

const summaries = [
  "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
];

const app = express()
const port = 3000

app.get('/GetWeatherForecast/', async (req, res) => {
  // Check, which permissions the user has for the city
  const permissions = await client.tenantApi.getTenantPermissions(
    "default",
    "city",
    req.query.city,
    req.query.user);

  // Get permissions for the user
  const canGetCurrentForecast = permissions["city"].Contains("get-current-forecast");
  const canGetFutureForecast = permissions["city"].Contains("get-future-forecast");
  if (!canGetCurrentForecast && !canGetFutureForecast) {
    res.status(403).send("You don't have permissions to access this resource.");
    return;
  }

  // Depending on the permissions, return the forecast for 1 or 5 days
  const forecastDays = canGetFutureForecast ? 5 : 1;

  // Generate the forecast  
  const forecast = Array.from({ length: forecastDays }, (_, index) => {
    const date = new Date();    
    date.setDate(date.getDate() + index);
    const temperatureC = Math.floor(Math.random() * (55 - (-20)) + (-20));
    const summary = summaries[Math.floor(Math.random() * summaries.length)];
    return {
      Date: date,
      TemperatureC: temperatureC,
      TemperatureF: 32 + Math.round(temperatureC / 0.5556),
      Summary: summary
    };
  });

  res.send(forecast);
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
