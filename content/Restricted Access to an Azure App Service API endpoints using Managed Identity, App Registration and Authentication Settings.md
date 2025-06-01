Problem statement

Terminologies
- caller
- callee

Azure configurations
- Callee
	- App Registration
	- Authentication Settings
		- Allowed Audience
		- Allowed Identities -> include caller's MI
		- Enable + 401
- Caller
	- Configure User/System-assigned managed identity -> provide MI to callee

Minimal Code example
- Caller generate access token to access callee

Using Credentials in different environments
- local environment: use VisualStudioCredential
- AVD environment: use ManagedIdentityCredential w/ explicit MI
- Azure environment (production): use ManagedIdentityCredential

How to get your ID for whitelisting in allowed identities
- az account get-access-token

Limitation
- exposing "public" page

