---
title: Restricted Access on Azure App Service API endpoints using Managed Identity, App Registration and Authentication Settings
date: 2025-06-04T00:55:00
draft: false
summary: Secure internal Azure App Service APIs using Managed Identity, App Registration, and built-in Authentication settings.
categories:
  - Dev
tags:
  - azure
  - managed-identity
  - app-registration
  - authentication
  - api
thumbnail: /posts/restricted-access-on-azure-app-service-api-endpoints-using-managed-identity-app-registration-and-authentication-settings/feature.png
---
# Overview

One of the projects I worked on recently is a new .NET API service (let's call it **Callee**) that runs on Azure using App Service. The client wants to implement a simple authentication solution to protect the API endpoints. The solution should only allow certain Azure app services, Azure Virtual Desktop instances and developers (let's call them **Caller(s)**) under same Azure Subscription to access the Callee. 

The following diagram illustrates the simplified authentication flow:

{{< mermaid >}}
sequenceDiagram

actor dev as Client (Caller)

participant guard as Azure App Service (Callee)

note over dev: Developer or<br>Consumer App Service

dev->>guard: makes an API request<br>(with object ID of the Azure resource)

guard->>guard: checks authentication settings

alt allowed

create participant producer as Protected API endpoint

guard->>producer: relays API request

destroy producer

producer->>dev: ✅ 200 OK

else unauthorized

guard->>dev: ❌ 401 Unauthorized

end
{{< /mermaid >}}

# Terminologies

We describe the protected .NET API service as the "**Callee**", while the client(s) that consuming the API resource are the "**Caller(s)**".

| Term       | Definition                                                                                                                     |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------ |
| **Callee** | The **receiver** or **provider** of the API request. It exposes the endpoint and handles the logic for fulfilling the request. |
| **Caller** | The **client** or **initiator** of the API request. It makes a call to another service to request data or trigger an action.   |
# Configurations on Azure

The overall idea is to set up the authentication settings on Callee. We only allow  HTTP requests from Caller(s) that contain a bearer access token with specific properties. The access token should be a JWT with allowed combination(s) of `aud` and `oid` values.

## Caller

Create an App Service called e.g. `poc-web-caller`.
Caller need to provide the identities and audiences to Callee in order to add them into allowed list.

### For an Azure App Service

1. Go to Caller's Azure App Service. In the left menu, choose **Settings** > **Identity**
2. Turn on the **system assigned managed identity**: ![[caller-system-mi.png]]
3. Keep the **Object (principal) ID**
4. Alternatively, you can choose user-assigned managed identity Object (principal) ID and assign the identity created: ![[caller-user-mi-step1.png]] ![[caller-user-mi-step2.png]]

### For an Azure Virtual Desktop instance
You will need to find out the **Object (Principal) ID** of the AVD instance.

>[!NOTE] Require administrator access
> You need administrator access to install Azure CLI

Install Azure CLI in PowerShell (run as administrator):
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest
```pwsh
winget install -e --id microsoft.AzureCLI
```

Start PowerShell as a regular user. Sign in to Azure and choose the correct subscription:
```
az login
```

Get the **Object (principal) ID** of the AVD instance:
```pwsh
az ad sp list --display-name "$Env:computername" --query "[0].id" -o tsv
```
### For an Azure Account user using Visual Studio
> [!NOTE]
> This approach also applies to a Mac or Linux user having Azure CLI installed

You will need to find out the **Object (Principal) ID** of your active account. Just like getting the ID from an AVD, you need to install Azure CLI.

```
Sign in to Azure and get the Object (principal) ID of the signed in user:
```pwsh
az login
az ad signed-in-user show --output tsv --query id
```
## Callee
Create an App Service called e.g. `poc-web-callee`.
### App Registration
> [!NOTE] 
> You need to create a new app registration if you don't have one.

1. Go to App Registration. Click **New registration**.
2. In your new registration:
	1. **Name**: user-facing display name for this application 
	2. **Supported account types**: We choose *Default Directory only - Single tenant* in this example
	3. **Redirect URI**: leave it empty
3. Click **Register**

### Azure App Service
1. Go to Callee's Azure Web Service. In the left menu, choose **Settings** > **Authentication**
2. Click **Add provider**. Choose **Microsoft**. ![[callee-auth-step1.png]] ![[callee-auth-step2.png]]
3. Fill in the details:
	1. **Choose a tenant for your application and its users**: *Workforce configuration (current tenant)*
	2. App registration
		1. **App registration type**: *Pick an existing app registration in this directory*
		2. Select the app registration you've created in **Name or app ID**
		3. **Client secret expiration**: choose the desired secret lifespan
	3. Additional checks
		1. **Client application requirement**: *Allow requests from any application*
		2. **Allowed client applications** (allowed audiences): 
			1. the app registration app ID you chose (for Azure app service)
			2. `https://management.core.windows.net/` (for localhost development)
		3. **Identity requirement**: *Allow requests from specific identities*
		4. **Allowed identities**: fill in one or some of the following items depends on your need:
			1. Caller's user assigned managed identity **Object (principal ID)**
			2. Caller's system-assigned managed identity **Object (principal ID)**
			3. (For localhost development) Azure Account's Object (principal) ID you got in the Caller configuration mentioned in previous section.
		5. **Tenant requirement**: *Allow requests only from the issuer tenant*
	4. App Service authentication settings
		1. **Restrict access**: *Require authentication*
		2. **Unauthenticated requests**: *HTTP 401 Unauthorized: recommended for APIs*
		3. **Token store**: checked
4. Click **Add** to add the identity provider
5. Click the **Edit** button next to Authentication settings, or the edit icon next to the identity provider to change the settings once it's created: ![[callee-auth-step3.png]]

The table below summarizes the information we need to configure the Callee's Authentication settings:

| Environment | Object ID (oid)                | Audience (aud)                         |
| ----------- | ------------------------------ | -------------------------------------- |
| Azure       | App service's managed identity | Callee's app registration ID           |
| AVD         | Machine's managed identity     | Callee's app registration ID           |
| Developer   | Personal access token          | `https://management.core.windoes.net/` |
Next, we will show some key code snippets on Caller. We will also create and deploy the sample Caller and Callee applications to show the authentication in action.
# Source code

A minimal example for caller and callee applications can be found in this GitHub:

{{< github repo="bemnlam/azure-managed-identity-auth " showThumbnail=true >}}

Here are some key points I want to highlight:
## Caller

### TokenCredential
A `TokenCredential` singleton can be created in app start:

```csharp
// In Startup.cs or Program.cs. 
// You should create different ChainedTokenCredential for different environments.
// This is a minimal example for demo purpose only.
builder.Services.AddSingleton<TokenCredential>(serviceProvider => {
  var objId = "YOUR_MANAGED_IDENTITY_OBJECT_ID";
  return new ChainedTokenCredential(
    new AzureCliCredential(), // for development only
    (string.IsNullOrEmpty(objId) ? 
	    new ManagedIdentityCredential() : // system assigned managed identity
	    new ManagedIdentityCredential(
		    ManagedIdentityId.FromUserAssignedObjectId(objId)
		) // user-assigned managed identity
	)
  );
});
```

You need to choose different credential provider under different environments.

| Environment                      | Recommended Credential                                                                                                                                                                     | Reason                                                                                                                                            |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Azure                            | [ManagedIdentityCredential(ManagedIdentityId) ](https://learn.microsoft.com/en-us/dotnet/api/azure.identity.managedidentitycredential?view=azure-dotnet)                                   | 1. An app service should have the managed identity. <br>2. You should provide it explicitly in order to avoid misuse of other managed identities. |
| AVD (Azure Virtual Desktop)      | [ManagedIdentityCredential()](https://learn.microsoft.com/en-us/dotnet/api/azure.identity.managedidentitycredential.-ctor?view=azure-dotnet#azure-identity-managedidentitycredential-ctor) | An AVD as a Azure resource under the same subscription should have a system assigned managed identity.                                            |
| Visual Studio with Azure Account | [VisualStudioCredential()](https://learn.microsoft.com/en-us/dotnet/api/azure.identity.visualstudiocredential?view=azure-dotnet)                                                           | Use the identity same as the user signed in in Visual Studio so that the Callee knows the Caller's identity.                                      |
| Mac                              | [AzureCliCredential](https://learn.microsoft.com/en-us/dotnet/api/azure.identity.azureclicredential?view=azure-dotnet)                                                                     | This is one of the clients you can use in Mac.                                                                                                    |
#### Note on DefaultAzureCredential and ChainedTokenCredential
I prefer using [ChainedTokenCredential](https://learn.microsoft.com/en-us/dotnet/api/azure.identity.chainedtokencredential?view=azure-dotnet), which allows me to choose which credential(s) to use, and define the attempt sequence that fits my requirement.

You may also consider using [DefaultAzureCredential](https://learn.microsoft.com/en-us/dotnet/api/azure.identity.defaultazurecredential?view=azure-dotnet) in non-production environments. However, using this might give you unexpected result because:
1. the attempt sequence might not in the desired order
2. you may not know which credential is picked eventually, unless you configure and inspect the logs

For example, if a developer signed in to Azure account in Visual Studio on an Azure Virtual Desktop instance, `DefaultAzureCredential` will attempt to authenticate with `ManagedIdentityCredential` before `VisualStudioCredential`. If the app want to use developer's personal identity over machine's identity, this will not work as expected.
### Access Token
The scope of the access token which Caller is going to generate is the Callee's app ID. Get an access token and add it as the Bearer authorization token when making API request to the Callee:

```csharp
// In Program.cs. You can also use the MVC pattern.
app.MapGet("/callee/protected-resource", async (IConfiguration configuration, TokenCredential credential) =>
{
	var myScope = "CALLEE_APP_REGISTRATION_ID";
	AccessToken token = await credential.GetTokenAsync(
		new TokenRequestContext(
			scopes: new[] { myScope }), 
			new CancellationTokenSource().Token
		)
	);
	using var httpClient = new HttpClient();
	httpClient.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token.Token);
	// make an HTTP request to a protected API endpoint of the Callee...
}
```

## Callee

Nothing special about the callee. 
Make sure sure that Azure is configured properly and let the Caller(s) know your Azure App Registration ID.

# Demo

Checkout the minimal GitHub repository:

{{< github repo="bemnlam/azure-managed-identity-auth " showThumbnail=true >}}

If you the following tools installed:
- [.NET SDK](vscode-file://vscode-app/Applications/Visual%20Studio%20Code.app/Contents/Resources/app/out/vs/code/electron-sandbox/workbench/workbench.html)
- [Visual Studio Code](vscode-file://vscode-app/Applications/Visual%20Studio%20Code.app/Contents/Resources/app/out/vs/code/electron-sandbox/workbench/workbench.html)
- [Azure CLI](vscode-file://vscode-app/Applications/Visual%20Studio%20Code.app/Contents/Resources/app/out/vs/code/electron-sandbox/workbench/workbench.html)
## Callee
- Open `poc-callee` in VS Code
- In VS Code, open the Command Palette and select **Azure: Deploy to Web App...** ![[callee-deploy-step1.png]]
- Choose **poc-callee**, add config and choose the Azure App Service: ![[callee-deploy-step2.png]] ![[callee-deploy-step3.png]]
- Expected result for a successful deployment:![[callee-deploy-succeeded.png]]
- Open Command Palette and select **Azure App Service: Browse Website**: ![[callee-deploy-browse.png]]
- You should see a webpage with a message `You do not have permission to view this directory or page`. That is expected because you don't have a valid access token.
## Caller
- Open `poc-caller` in VS Code
- Modify `appsettings.json`:
	- **CalleeApi**: the root url of the Callee e.g. *https://{callee-app-name}-{random-hash}.{region}-01.azurewebsites.net/*
	- **CalleeAppRegistrationId**: the App Registration ID of the Callee
	- **ManagedIdentity**: Caller's user/system-assigned managed identity Object (Principal) ID
- Choose **poc-caller**, add the config and choose the Azure App Service: ![[caller-deploy-step1.png]]
- Expected result for a successful deployment: ![[caller-deploy-succeeded.png]]
- Choose **Azure App Service: Browse Website** in Command Palette. You should be able to see a Swagger UI.
- Call `GET /remote-ping` endpoint and you should see a 200 response. The response body should contains a greeting message and a token: ![[demo-result-succeeded.png]]

# Local Development
If you want to run Caller locally, and call the Callee API endpoints which hosting on Azure, you will need to:
1. Get your personal Object (principal) ID (if you are using Azure CLI or signed in user in Visual Studio)
2. Add the Object (principal) ID to Callee's **allowed identities**
3. Add `https://management.core.windows.net/` to Callee's **Allowed token audiences**

# Limitations
This is a simple, all-or-nothing authentication solution for the Callee app. In other words, you can't make certain endpoints public while the others keep protected.  Also, there will be some code changes in order to let all Caller apps be able to get an Azure access token.

# Conclusion
In this post, we demonstrated how to secure Azure App Service API endpoints using Managed Identity, App Registration, and built-in Authentication settings. This approach enables access control across services and environments within the same Azure subscription without requiring custom authentication logic. While simple and effective, it’s best suited for internal APIs where all access can be gated uniformly.

# References
- https://learn.microsoft.com/en-us/dotnet/api/azure.identity.defaultazurecredential?view=azure-dotnet
- https://techcommunity.microsoft.com/blog/microsoft-security-blog/add-authentication-to-your-azure-app-service-or-function-app-using-microsoft-ent/4372492
- https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app
- https://jwt.io/
- https://learn.microsoft.com/en-us/azure/healthcare-apis/get-access-token?tabs=azure-cli
- https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview
- https://learn.microsoft.com/en-us/dotnet/api/microsoft.identity.client.appconfig.managedidentityid?view=msal-dotnet-latest
- https://learn.microsoft.com/en-us/azure/app-service/scenario-secure-app-authentication-app-service?tabs=workforce-configuration
- 

