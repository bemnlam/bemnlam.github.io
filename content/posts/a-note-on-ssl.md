---
title: "A Note on SSL Certificate"
summary: This is a note about the Linkedin learning course SSL Certificates for Web Developers.
date: 2020-05-23T17:10:25+08:00
draft: false
categories: ["Dev"]
tags: ["ssl", "cryptography", "https", "security", "linkedin-digest"]
thumbnail: https://images.unsplash.com/photo-1506967726964-da9127fdec36?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1000&q=60
---

This is a note about the Linkedin learning course [SSL Certificates for Web Developers](https://www.linkedin.com/learning/ssl-certificates-for-web-developers).

## Certificate and protocol

### What are SSL/TLS stands for?

They stands for *Secure Socket Layer* and *Transport Layer Security*. They are the protocol names.

### What is HTTPS, and why we are using it?

Https[ecure], a protocol on top of HTTP to secure the integrity of the data sending form the user to server. 

###  What is a certificate, and what is it for?

A certificate [^1] (`.crt`, `.cer`) certifies **the ownership of a public key**. A certificate contains:

- organization, 
- issuer (e.g. the Certificate Authority / Self-signed), 
- valid period, 
- url,
- **state / country**

These information can be used to identify the certificate owner.

The public key is used to **encrypt**/~~decrypt~~ the communication between computers.

---

## Cryptography

### Asymmetric VS. Symmetric

Asymmetric cryptography requies a pair of keys. The *Public key* is used to encrypt messages while the *private key* is for decryption. 

In symmetric cryptography, both ends use the same password to encrypt + decrypt messages.

### Why are we using both technologies? And how?

In short: For the balance of security and speed, we use asymmetric cryptography to establish secure connection (*handshake*) and use symmetric cryptography for the data transmission.

#### The Handshake

The end user and the server use the same password to encrypt + decrypt the messages. This password is sent from a server to a user by following steps:

- Validate the certificate...
  1. User makes a request to a web server.
  2. Web server responds with its *public key* certificate.
  3. User checks if the *public key* certificate is valid.
- If the certificate from web server is valid...
  1. User encrypts the password using server's public key, and send to web server.
  2. Server decrypts with its private key. 

After that, a secure connection is established and they shared the *same* password [^2].

---

## Types of certificate

### Self-signed

- Intra-communications between systems under same organization.
- Local development

### CA

- Subdomain: tied to 1 domain (e.g. `www.mydoma.in`)
- Wildcard: tied to a groups of subdomains (e.g. `*.mydoma.in`)
- Multi-domain: (e.g. `mydoma.in`, `myweb.site`, ...)

---

## ACME (Automatic Certificate Management Environment)

To configuring Let's Encrypt's ACME on server, we can make use of the [CertBot](https://certbot.eff.org/). For IIS, use [Certify](https://certifytheweb.com/).

### 

---

## HSTS

This can instruct the browser to interact with the server with HTTPS only. Redirect from HTTP to HTTPS is not required. This is achieved by adding a response header (`Strict-Transport-Security`).

Example response header:

```ini
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```

### What HSTS is protecting us from?

The **Man-in-the-Middle TLS Protocol Downgrade Attack.**[^3] In [this example](https://www.praetorian.com/blog/man-in-the-middle-tls-ssl-protocol-downgrade-attack), the hacker C sends a ARP cache table request to both the client A and server B:
![Manipulating Device ARP Cache Tables](https://assets.website-files.com/58866caeabc83d5e7c574c74/5cdc9328fcbd747340785c63_20140811-mitm-attack.png)

Now the traffic from A to B is going through C, a typical **Man-in-the-Middle attack**.

The next step is C try to have a **downgrade** on the TLS version. Since the browsers are backward-compatible on older TLS versions, C can therefore to make the version downgraded to the negotiated version in the handshake process. C can then intercept and decrypt the messages by making use of the security vulnerabilities of eariler TLS.

### HSTS Preloading

Avoid redirection of the first request too: https://hstspreload.org/



[^1]: the certificate does not depends on the protocol we use
[^2]:password is just for the same browsing session.
[^3]: I am not an expert on this area and I tried by best to digest that article and [this wiki](https://en.m.wikipedia.org/wiki/Downgrade_attack) to write the summary.