---
title: "A Tale of Two Caches: Redis and the cache helper"
summary: A note on how to add Redis and the cache helper to a .NET core Mvc app.
date: 2020-06-11T21:06:59+08:00
lastmod: 2020-06-27T17:06:24+08:00
draft: false
categories: ["Dev"]
tags: ["tutorial", "csharp", ".NET Core", "cache", "redis", "tag-helpers"]
thumbnail: /posts/a-tale-of-two-caches-redis-and-cache-helper/thumbnail.png
---

## Background ##

Recently our team started a new project: a showcase page under our main website. The website is read-only and the content won't change frequently so we can have an aggressive caching policy.

I built this **MVC** web app using **.NET Core 3.1** and deploy it as an IIS sub-site under the main website (which is a **.NET Framework** web app running on the IIS).

### Table of Contents

- [Redis](#redis)
    - [NuGet package](#redis-nuget)
    - [appsettings.json](#redis-appsettings)
    - [Startup.cs](#redis-startup)
    - [CacheService](#redis-cache-service)
    - [Controller](#redis-controller)
- [Cache Tag Helper](#cache-tag-helper)
    - [Example](#cache-tag-helper-example)
    - [Explaination](#cache-tag-helper-exaplain)
- [Bonus: A note on @helper and other HTML helpers](#bonus)

---

## Redis {#redis} ##
### Why? ###

We are using [Redis](https://redis.io/) because it is simple, fast and we are already using it across all the main websites.

### How? ###

Here are some highlights:

#### 1. NuGet packages {#redis-nuget} ####
```xml
<PackageReference Include="StackExchange.Redis" Version="2.1.30" />
<PackageReference Include="StackExchange.Redis.Extensions.Core" Version="6.1.7" />
<PackageReference Include="StackExchange.Redis.Extensions.Newtonsoft" Version="6.1.7" />
<PackageReference Include="StackExchange.Redis.Extensions.AspNetCore" Version="6.1.7" />
```

`StackExchange.Redis.Extensions.Newtonsoft` is optional. [Start from .NET Core 3.0](https://devblogs.microsoft.com/dotnet/try-the-new-system-text-json-apis/) the default Json serializer will be `System.Text.Json`. If you want to use `Newtonsoft.Json` then you will need this package in your project.

`StackExchange.Redis.Extensions.Core` and `StackExchange.Redis.Extensions.AspNetCore` are the useful package to connect/read/write Redis easier. Read [this documentation](https://stackexchange-redis-extensinos.gitbook.io/stackexchange-redis-extensions/) for more details.

#### 2. appsettings.json {#redis-appsettings} ####

A typical .NET Core project should have an `appsettings.json`. Add the following section:

```json
{
  "Redis": {
    "AllowAdmin": false,
    "Ssl": false,
    "ConnectTimeout": 6000,
    "ConnectRetry": 2,
    "Database": 0,
    "Hosts": [
      {
        "Host": "my-secret-redis-host.com",
        "Port": "6379"
      }
    ]
  } 
}
```
Here, `my-secret-redis-host.com` is the Redis host and We are using the database no. `0`. You can set multiple hosts. You can see a detailed configuration [here](https://stackexchange-redis-extensinos.gitbook.io/stackexchange-redis-extensions/configuration/json-configuration).

#### 3. Startup.cs {#redis-startup} ####
Add the following code in `ConfigureServices()`
```cs
var redisConfiguration = Configuration.GetSection("Redis").Get<RedisConfiguration>();
services.AddStackExchangeRedisExtensions<NewtonsoftSerializer>(redisConfiguration);
```
#### 5. CacheService {#redis-cache-service} ####
I created a `CacheService.cs` to help me reading/writing data in Redis. In this service:

```cs
public CacheService(RedisConfiguration redisConfiguration, ILogger<RedisCacheConnectionPoolManager> poolLogger)
{
    try
    {
        var connectionPoolManager = new RedisCacheConnectionPoolManager(redisConfiguration, poolLogger);
        _redisClient = new RedisCacheClient(connectionPoolManager, serializer, redisConfiguration);
    }
    catch(Exception ex)
    {
        /* something wrong when connection to Redis servers. */
    }
    _cacheDuration = 300; // cache period in seconds
}
```

We need a method to write data:
```csharp
public async Task<bool> AddAsync(string key, object value)
{
    try
    {
        bool added = await _redisClient.GetDbFromConfiguration().AddAsync(key, value, DateTimeOffset.Now.AddSeconds(_cacheDuration));
        return added;
    }
    catch (Exception ex)
    {
        /* something wrong when writing data to Redis */
        return false;
    }
}
```

And we need a method to get cached data:
```csharp
public async Task<T> TryGetAsync<T>(string key)
{
    try
    {
        if(await _redisClient.GetDbFromConfiguration().ExistsAsync(key))
        {
            return await _redisClient.GetDbFromConfiguration().GetAsync<T>(key);
        }
        else
        {
            return default;
        }
    }
    catch(Exception ex)
    {
        /* something wrong when writing data to Redis */
        return default;
    }
}
```

I intentionally name this method `TryGetAsync()` because the cache may not exist or already expired when you try to get it from Redis.

After that, let's go back to `Startup.cs` and register this service in `ConfigureService()`:
```cs
services.AddTransient<CacheService>();
```

Remember to register this service **after** `services.AddStackExchangeRedisExtensions()`.

#### 5. Controller {#redis-controller} ###
Inject the `CacheService` to the controller:
```csharp
public DemoController(CacheService cacheService)
{
    _cacheService = cacheService;
}


public async Task<IActionResult> Demo(string name)
{
    var cacheKey = $"DemoApp:{name}";

    // Try to get cached value from Redis.
    string cachedResult = await _cacheService.TryGetAsync<string>(cacheKey);
    if(default != cachedResult)
    {
        return View(cachedResult);
    }

    // Add a new entry to Redis before returning the message.
    var message = $"Hello, {name}";
    if(null != sections && sections.Any())
    {
        await _cacheService.AddAsync(cacheKey, message);
    }

    return View(message);
}
```

> **Explain Like I'm Five**: 
>
> You ask the shopkeeper in `Demo` bookstore do they have a specific book `name`. First, the shopkeeper looks for the book on the bookshelf named `Redis`. If he finds that book, he takes it out and gives it to you.
>
> If your book does not exist in the `Redis` bookstore, he has to go out and buy that book for you(!). However, he buys 2 identical copies. He gives you one and puts the other one on the `Redis` bookshelf, just in case another customer want that book later.

---

## Cache Tag Helper {#cache-tag-helper} ##

The [Cache Tag Helper](https://docs.microsoft.com/en-us/aspnet/core/mvc/views/tag-helpers/built-in/cache-tag-helper?view=aspnetcore-3.1) is a tag that you can use in a **.NET Core MVC** app. Content encolsed by this `<cache>` tag will be cached in the internal cache provider.

### Example {#cache-tag-helper-example} ###
```html
<cache expires-after="@TimeSpan.FromSeconds(60)" 
       vary-by-route="name" 
       vary-by-user="false">
	@System.DateTime.Now
</cache>
```

### Explaination {#cache-tag-helper-exaplain} ###
In the above example, some attributes is set in the `<cache>` tag:
- `expires-after`: how long (in seconds) will this cache last for.
- `vary-by-route`: different copy will be cached when the route has a different value in the `name`param.
- `vary-by-user`: different user will see different cached copies.

### How can I know if it is working? ###

You will see the value rendered in the above example won't change for 60 seconds even `System.DateTime.Now` should show the current time.

---

## Bonus: A note on `@helper` and other HTML helpers {#bonus}  ##

In the old days we can define some `@helper` functions in the razor view and (re)use it in the view. It's being removed since .NET Core 3.0 because the design of `@helper` function does not compatible with async Razor content anymore.

### Successor of the HTML helpers? ###

You can use the [**Tag Helpers in ASP.NET Core**](https://docs.microsoft.com/en-us/aspnet/core/mvc/views/tag-helpers/intro?view=aspnetcore-3.1). Yes, the `<cache>` Tag Helper is one of the [built-in Tag Helpers in .NET Core](https://docs.microsoft.com/en-us/aspnet/core/mvc/views/tag-helpers/intro?view=aspnetcore-3.1#built-in-aspnet-core-tag-helpers).

In addition, you can use the [`PartialAsync()` method](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.mvc.rendering.htmlhelperpartialextensions.partialasync?view=aspnetcore-3.1)  to render the partial HTML markup **asynchronously**.

```csharp
@await Html.PartialAsync("_PartialName")
```

---

**More references on the HTML helpers and Tag Helpers:**

[What happened to the @helper directive in Razor ?](https://github.com/aspnet/Mvc/issues/4127)

[Remove the @helper directive from Razor](https://github.com/aspnet/Razor/issues/281)

[ASP.NET Core 1.0: Goodbye HTML helpers and hello TagHelpers!](https://dannyvanderkraan.wordpress.com/2016/04/19/asp-net-core-1-0-goodbye-html-helpers-and-hello-taghelpers/)
