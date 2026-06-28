---
title: Accessing Calibre from Anywhere Using Cloudflare Tunnel
summary: Access your Calibre library outside your home network — set it up once with Cloudflare Tunnel
date: 2026-06-28T14:00:00-05:00
draft: false
categories:
  - Dev
tags:
  - cloudflare
  - tutorial
  - setup
thumbnail: /posts/accessing-calibre-anywhere/feature.jpg
---

Calibre has a "Content Server" feature. User can visit its Content Server via http://localhost:8080 if Calibre is running with content server is turned on by default.
However, the content server is only accessible within the same WiFi network, meaning that you cannot read ebooks with mobile device outside home network.

Cloudflare Tunnel makes your Calibre Content Server accessible from anywhere by tunnelling a public domain traffic to the server that runs on your machine locally, if you have a custom domain.


```mermaid
sequenceDiagram
	actor user
	participant browser
	participant cloudflare
	participant macbook
	
	user->>browser: visit https://calibre.myhost.com
	browser->>cloudflare: DNS and cloudflared routing
	cloudflare->>macbook: reach http://localhost:8080, Calibre's default content server
	macbook->>browser: serve Calibre's default content server via defined host
	browser->>user: read ebooks via Calibre's content server
```

### Assumptions
1. you own a domain `myhost.com` and it's managed by Cloudflare.
2. you are about to create a subdomain calibre.myhost.com for tunnelling public traffic.
3. the tunnel you are about to create is `Calibre`.

Sign in to the dashboard https://dash.cloudflare.com. Choose **Networking** > **Tunnel** at the left menu. Click **+ Create Tunnel**:
![[Pasted image 20260628143210.png]]

Name your tunnel (case-sensitive), then click **Create Tunnel**:
![[Pasted image 20260628143238.png]]

Follow the instruction to set up tunnel service on your machine. For me as a Mac user, I install cloudflared via homebrew:

```bash
brew install cloudflared
```

Then, you need `sudo` and type your password to install the service:

```
sudo cloudflared service install <the token>
```

If you want to run cloudflared manually (a foreground process):

```bash
cloudflared tunnel run --token <the token>
```

![[Pasted image 20260628143805.png]]

You should see a "Tunnel connected successfully" message if connection is established. Click **Continue**

Login to Cloudflare in cloudflared

```bash
❯ cloudflared tunnel login
A browser window should have opened at the following URL:

https://dash.cloudflare.com/argotunnel?aud=&callback=xxx

If the browser failed to open, please visit the URL above directly in your browser.
2026-06-28T19:44:10Z INF You have successfully logged in.
If you wish to copy your credentials to a server, they have been saved to:
/Users/<your-user-name>/.cloudflared/cert.pem
```

Find out the tunnel id:
```bash
❯ cloudflared tunnel list
You can obtain more detailed information for each tunnel with `cloudflared tunnel info <name/uuid>`
ID                                   NAME    CREATED              CONNECTIONS
<tunnel-uuid> Calibre 2026-06-28T19:32:41Z
```
You can see the CONNECTIONS is empty, meaning that this tunnel is not running yet.

Create a config file:
```
❯ sudo mkdir -p /etc/cloudflared
sudo touch /etc/cloudflared/config.yml
```

In the config.yml file:

```yml
tunnel: <tunnel-uuid>
credentials-file: /etc/cloudflared/<tunnel-uuid>.json

ingress:

  - hostname: https://calibre.myhost.com
    service: http://localhost:8080
  - service: http_status:404
```


Create the tunnel json file:
```bash
cloudflared tunnel token --cred-file ~/.cloudflared/<tunnel-uuid>.json Calibre
sudo cp ~/.cloudflared/<tunnel-uuid>.json /etc/cloudflared/
```

Restart the service:
```bash
sudo cloudflared service uninstall 
sudo cloudflared service install 
```

Modify the plist file `/Library/LaunchDaemons/com.cloudflare.cloudflared.plist`, add `tunnel` and `run` to the `ProgramArguments` array:

```xml
<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.cloudflare.cloudflared</string>
	<key>ProgramArguments</key>
		<array>
			<string>/opt/homebrew/bin/cloudflared</string>
			<string>tunnel</string>
			<string>run</string>
		</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StandardOutPath</key>
	<string>/Library/Logs/com.cloudflare.cloudflared.out.log</string>
	<key>StandardErrorPath</key>
	<string>/Library/Logs/com.cloudflare.cloudflared.err.log</string>
	<key>KeepAlive</key>
	<dict>
		<key>SuccessfulExit</key>
		<false/>
	</dict>
	<key>ThrottleInterval</key>
	<integer>5</integer>
</dict>
</plist>
```


Add DNS record
click **"+ add route**:
![[Pasted image 20260628153345.png]]

choose **published application**:
![[Pasted image 20260628153401.png]]

fill in the subdomain (`calibre`) and service URL (`http://localhost:8080`)
You should see a "Route added successfully" message

Then, visit https://calibre.myhost.com and you should see Calibre's content server.