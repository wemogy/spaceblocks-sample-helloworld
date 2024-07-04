from datetime import date, timedelta
from random import randint, choice

from fastapi import FastAPI, HTTPException
from spaceblocks_permissions_server import PermissionsClient, ClientAuthenticationOptions

SUMMARIES = ['Freezing', 'Bracing', 'Chilly', 'Cool', 'Mild', 'Warm', 'Balmy', 'Hot', 'Sweltering', 'Scorching']

app = FastAPI()

permissions_client = PermissionsClient(
    '<YOUR_PERMISSIONS_URL>',
    ClientAuthenticationOptions(
        api_key='<YOUR_API_KEY>',
        client_id='<YOUR_CLIENT_ID>',
        client_secret='<YOUR_CLIENT_SECRET>',
        scopes='permissions:management:read permissions:management:write'
    )
)


@app.get('/get-weather-forecast/')
def get_weather_forecast(user: str, city: str):
    permissions = permissions_client.permission_api.list_permissions(
        'default',
        'city',
        city,
        user
    )

    can_get_current_forecast = 'current-forecast-viewer' in permissions['city']
    can_get_future_forecast = 'future-forecast-viewer' in permissions['city']

    if not can_get_current_forecast and not can_get_future_forecast:
        raise HTTPException(status_code=403, detail='No permission')

    return [{
                'date': date.today() + timedelta(days=i+1),
                'temperature': randint(-5, 38),
                'summary': choice(SUMMARIES)
            } for i in range(5 if can_get_future_forecast else 1)]
