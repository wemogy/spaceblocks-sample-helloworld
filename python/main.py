from fastapi import FastAPI
from spaceblocks_permissions_server import PermissionsClient, ClientAuthenticationOptions, ResourceMembers

app = FastAPI()

permissions_client = PermissionsClient(
    '<YOUR_PERMISSIONS_URL>',
    ClientAuthenticationOptions(
        api_key='<YOUR_API_KEY>',
        client_id='<YOUR_CLIENT_ID>',
        client_secret='<YOUR_CLIENT_SECRET>'
    )
)


@app.get('/get-weather-forecast/')
def get_weather_forecast(user: str, city: str):
    has_permission: bool = permissions_client.permission_api.check_permissions(
        'default',
        'city',
        city,
        user,
        'city',
        ['get-current-forecast']
    )

    if not has_permission:
        return 'No permission'

    return 'Hello World!'
