---
title: "⚙️ Setting Up Nginx for Local Development"
summary: "Let's have HTTPS all the way, locally."
date: 2023-08-17T07:59:39-05:00
draft: false
categories: ["Dev"]
tags: ["nginx", "obs", "setup"]
thumbnail: https://images.unsplash.com/photo-1600074169098-16a54d791d0d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3Dauto=format&fit=crop&w=1000&q=60
---

Having a proper local development environment is crucial for building and testing applications efficiently. One tool that can really enhance your local dev environment is Nginx.

In this post, I'll explain how to install Nginx and configure it for local development with HTTPS enabled.


## What is Nginx?

Nginx can help you to run multiple local development servers. For example, you may have a React app running on port 3000 and a C# API running on port 5000. In this case, it acts as a [reverse proxy](https://www.notion.so/Setting-up-Nginx-for-Local-Development-ae53177af32c426bb9a4695961dc20de?pvs=21) to route requests to these different services.

We can also adding a SSL certificate to specific domain such that the website traffic can be served via HTTPS.

## Some Practical Scenarios in Local Development

There are a few scenarios where using HTTPS in local development is a must:

- Testing functionality that requires a secure context like SSO login, service workers, Geolocation API etc.
- Avoiding mixed content warnings when loading scripts, styles, images etc.

Enabling HTTPS for local development helps address these issues and improves the development experience.

## Installation

### Mac

Use [homebrew](https://brew.sh/) to install Nginx:

```bash
brew install nginx
```

After that, add it as a service to start Nginx automatically:

```bash
brew services start nginx
```

Go to [http://localhost:8888](http://localhost:8888) and you should be able to see a "Welcome to Nginx!" message.

- Installation directory: `/opt/homebrew/bin/nginx`
- Document directory: `/opt/homebrew/var/www`

### Windows

Download the latest stable release from [https://nginx.org/en/docs/windows.html](https://nginx.org/en/docs/windows.html) and run the exe file.

The installation and document directories will be the same directory as your extracted Nginx folder.

After that, start Nginx manually:

```powershell
start nginx.exe 
```

Go to [http://localhost](http://localhost) and you should be able to see a "Welcome to Nginx!" message.

## Generating the SSL Certificate with `mkcert`

To enable HTTPS on localhost, we need to generate an SSL certificate.

We need **mkcert** to generate the certificate.

### Install `mkcert`

#### Mac

Use homebrew to install mkcert

```bash
brew install mkcert
```

#### Windows

Download mkcert here: https://github.com/FiloSottile/mkcert/releases

### Generate and Install the Certificate

Next, we can generate and install the certificate using mkcert.

1. Generate SSL cert. For example, for *localhost*:

```bash
./mkcert localhost
```

This will generate a public key file `localhost-key.pem` and a private key file `localhost.pem`.

> Note: Change form [localhost](http://localhost) to your custom domain when you want to server your website from that domain.
>

2. Install the SSL certificate.

```bash
./mkcert -install
```

In Windows, a prompt will be shown telling us we are going to add the certificate to the local cert store.

## Configuring Nginx

We are going to add a new Nginx configuration file.

Some key parts:

- Map port 3001 to a proxied local development server on port 3000
- Enable SSL using the generated certificate
- Proxy headers for proper websocket support (which is required for hot-reloading on React app)

Add this line in `nginx.conf` to include the new config file we are going to create:

```nginx
## Add this to the last line of the `server` block in nginx.conf
include localhost.conf;
```

After that, create a new Nginx conf file named `localhost.conf`. For Mac, place it under `servers/` directory; for Windows, place it under same directory with `nginx.conf`:

```nginx
## We need this upgrade header for WebSocket
## https://www.nginx.com/blog/websocket-nginx/
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

## Assuming you are running a React App on localhost:3000
upstream localsite {
    server localhost:3000;
}

## Assuming you are running a API server on localhost:5000
upstream localapi {
    server localhost:5000;
}

## Setting up localhost:3001 for HTTPS and WebSocket
server {
    listen 3001 ssl;
    listen [::]:3001 ssl;

    server_name localhost;

		## The location of the key files. 
		## You can put a relative directory, 
		## or set the absolute path of the file
    ssl_certificate ../certs/localhost.pem;
    ssl_certificate_key ../certs/localhost-key.pem;
    ssl_prefer_server_ciphers on;

    ## https://www.nginx.com/blog/websocket-nginx/
    location / {
        proxy_pass http://localsite;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
    }

		## Assuming you want to serve the APIs under localhost:3001/api
		location /api {
        proxy_pass http://localapi;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
    }
}
```

Now requests to `https://localhost:3001` will be proxied to the local React app dev server on port 3000 with HTTPS enabled.

Also, requests with Url prefix `https://localhost:3001/api` will be proxied to the API server on port 5000.

## Github Examples

An example React app: [https://github.com/bemnlam/vite-preset](https://github.com/bemnlam/vite-preset)

You can also find the example Nginx config here: [https://github.com/bemnlam/vite-preset/blob/master/public/local-ssl.conf](https://github.com/bemnlam/vite-preset/blob/master/public/local-ssl.conf)

## Final Notes

With Nginx installed and configured, you can easily spin up multiple local development servers and access them all through Nginx reverse proxy with HTTPS enabled. No more "site can't be reached" errors!

---

## References

1. [https://www.nginx.com/resources/glossary/reverse-proxy-server](https://www.nginx.com/resources/glossary/reverse-proxy-server/#:~:text=A%20reverse%20proxy%20server%20is,traffic%20between%20clients%20and%20servers)
2. [https://nginx.org/en/docs/http/websocket.html](https://nginx.org/en/docs/http/websocket.html)
3. [https://formulae.brew.sh/formula/nginx](https://formulae.brew.sh/formula/nginx)
4. [https://github.com/FiloSottile/mkcert](https://github.com/FiloSottile/mkcert)
5. [https://github.com/bemnlam/vite-preset](https://github.com/bemnlam/vite-preset)
6. [https://stackoverflow.com/a/71447914](https://stackoverflow.com/a/71447914)