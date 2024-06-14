# Space Blocks Sample HelloWorld

## Setup

The permissions structure is desribed in the blog [Quickly add permission checks to your ASP.NET apps
](https://www.spaceblocks.cloud/blog/quickly-add-permission-checks-to-your-asp-net-apps).

Alternativly, the `setup.sh` script creates these structures via the API.

There is also a `seeding.sh` script that puts some demo data into Permissions.

Both scripts ask for the needed credentials / information.
To avoid having to enter them again and again, create a `secrets.json` that looks like this:

```json
{
    "permissionsUrl": "",
    "apiKey": "",
    "projectId": "",
    "environmentId": "",
    "clientId": "",
    "clientSecret": ""
}
```
Then run the scripts with the `--secrets-from-file` flag.
