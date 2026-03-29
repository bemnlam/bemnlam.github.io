# Agent Instructions: Blog Migration to Cloudflare Pages

## 1. Project Context
- **Source Repository:** bemnlam/bemnlam.github.io
- **Target Domain:** blog.lofibean.cc
- **Framework:** Hugo (Static Site Generator)
- **Primary Branch:** main

## 2. Prerequisites (User to Provide)
Ensure the following environment variables are available to the agent:
- `CLOUDFLARE_API_TOKEN`: Token with 'Cloudflare Pages: Edit' permissions.
- `CLOUDFLARE_ACCOUNT_ID`: Your Cloudflare account ID.
- `HUGO_VERSION`: The version used in existing GitHub Actions (e.g., "0.123.0").

## 3. Implementation Steps

### Step A: Initialize Configuration
Create a `wrangler.toml` file in the repository root to define build behavior.

```toml
#:schema node_modules/wrangler/config-schema.json
name = "lofibean-blog"
pages_build_output_dir = "public"

[build]
command = "hugo --minify"

[vars]
HUGO_VERSION = "0.123.0"

---

# Create Project & Link GitHub (API Call)

The agent should execute this POST request to create the project and establish the Git connection.

```bash
curl -X POST "[https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects](https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects)" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "name": "lofibean-blog",
       "production_branch": "main",
       "source": {
         "type": "github",
         "config": {
           "owner": "bemnlam",
           "repo_name": "bemnlam.github.io",
           "production_branch": "main",
           "pr_comments_enabled": true,
           "deployments_enabled": true
         }
       },
       "deployment_configs": {
         "production": {
           "env_vars": {
             "HUGO_VERSION": { "value": "0.123.0" }
           }
         }
       }
     }'
```

# Attach Custom Domain (API Call)

Execute this request once the project creation is confirmed.

```bash
curl -X POST "[https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/lofibean-blog/domains](https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/lofibean-blog/domains)" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{ "name": "blog.lofibean.cc" }'
```

# Hugo Configuration Update

Update hugo.toml (or config.toml) to ensure the baseURL matches the custom domain.

```bash
baseURL = '[https://blog.lofibean.cc/](https://blog.lofibean.cc/)'
```