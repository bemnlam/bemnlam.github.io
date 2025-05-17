---
title: "Notes on Bamboo Preface"
date: 2020-09-13T14:01:59+08:00
draft: true
---

## Purpose of this note

One of the major task I have done since I work in the current company is to setting up and maintain CI/CD pipelines to build and deploy .NET websites (including .NET MVC, ASP.NET WebSite / Web Application) and nuget libraries.

I met lots of weired problems. Some of them is related to MSBuild, some of them are related to MSDeploy and some of them are related to the web servers running the websites.

This is a note on how I set up those pipelines (together w/ the build server) and solve some of the weired problems. Hope that this note can save me in the furure, or someone in the internet who are searching for the answer.

## From FTP to Atlassian Bamboo

### The starting point: ~2017 Fall

Before I started working on the CI/CD pipelines, someone in my team set up a windows server with Bamboo installed. Some internal nuget packages are built on it and deployed to MyGet private feed.

Before that, *any team members* can click the **Build** or **Publish** button in their own Visual Studio. After that, they **copied** the published nuget package or upload the website via **FTP**.

No (version) control in those websites at all.

At first, I wrote a Node.js script to inject a version file in to the built website folder and then call ftp to upload that stuff. Stupid but at least I know what version is running on the server.

Later, the teammate who set up Bamboo left the company. As a web developer I knew I had to set up the proper build/deploy workflows.

### What are those: websites and class libraries

Although the development team has just 3 members at that time, we had to maintain/develop the following websites:

- A .NET Core MVC sub-web application running on .NET Core 3.1 (new website)
- Few .NET MVC (sub) web applications running on .NET Framework 4.5.1 (new websites)
- Few .NET WebForm Web Applicatoin running on .NET Framework 4.5.1 (old websites)
- Few .NET WebForm Website running on .NET Framework 3.5 (CMS)
- The class libraries shared by the websites / CMS, targeting .NET Framework 3.5 / 4.5.1

Plus, some websites need to run gulp to generate css / js.

Once again, I can't imagine how and how much time the team need to do to just deploying 1 website / library. However, it's clearly unmanagable.

## Build a website. And then deploy it. Is that correct?

My previous company build the website using **TeamCity** and deploy it to web server using a taolor-made deployment tool.

~~Luckily, Atlassian Bamboo combines both of them. In Bamboo, a *build plan* is dealing with the build process and for deployment, it has *deployment plan*.~~

So first step is building the website. That should be easy, right?

### The thing I wish I know...

The thing I wish to tell myself in 2017 is: "No, please don't plan it from *how you build a website*.". Instead, try to design your CI/CD flow from thinking of **how your app is hosting** (on a web server / a class library repository).

If you know your objective, you will know how to set up the steps to go there.

### Designing a CI/CD workflow

In short, this is all related to **predictability**. For all the developers.

#### Know your deployment project/plans

**Deployment plan**

When a request is coming to your website:

1. The request will go through your infrastructure (e.g. a load balancer)
2. The load balancer routes the request to one of your web servers (e.g. a Windows web server runnning IIS)
3. The IIS website running in a particular env. (e.g. a `web.Production.config`) gives you a response.

Therefore, the relationship between *deployment plan* and website environment should be a 1-1 mapping.

<iframe frameborder="0" style="width:100%;height:193px;" src="https://viewer.diagrams.net/?highlight=0000ff&edit=_blank&layers=1&nav=1&page-id=5NTDSoxaS2X6YF9Ro-iN&title=Untitled%20Diagram.drawio#R%3Cmxfile%3E%3Cdiagram%20id%3D%22OcZ6xrIXlFfuIMR6o8_5%22%20name%3D%22Page-1%22%3E7Vxtb%2BI4EP41SLsngcgbhI%2FQbvd66umqpXe7%2BwmZxATvJnHkmAL362%2Bc2CTBoUBbSLtHK5Vk4vjlecYzHo9py7qKVp8ZSuZ%2FUh%2BHLbPrr1rWdcs0jZ7rwIeQrHOJ0%2B3lgoARXxYqBGPyL5bCrpQuiI%2FTSkFOachJUhV6NI6xxysyxBhdVovNaFhtNUEB1gRjD4W69Cvx%2BTyXuk63kP%2BOSTBXLRtd%2BSRCqrAUpHPk02VJZH1qWVeMUp5fRasrHArwFC75ezc7nv7RjgZf%2Fnl8%2BNy%2B%2F8v9uZ7ePaxwW2L7iMKF7P8YQCE0TmUf%2BFoNTPWf4Zg%2Fu72%2B1t41TkK6jkSlZvc%2BRLHWcLokEcjhbiTfxozj1RbcRbd2D1R29DOmEeZsDe%2FJWkxXYi6VTt0uCwYNRyrmvMSerbhCUmuCTdUFMnAhwTkCKFcD6vZ2DIIxZjB8nZ0SSClHjMuJYVonRM3u70dNTcsyalb%2FVKhZhgbbaEFgBjenWs5%2BjAbHYiQb%2BwJTFcUBDOaY1qya1kBNKo2hkGMWI45HdBH7qcbLZpgvoMrZTRWjP4RpboCttmFXEXR0BK06vmzj1%2BFLn0S3HEfpqzgAve6W2QuhvpFPHuEyEJd%2FDx%2BUFKovPdBUAqVJ7sRnZIWh3VGCGYGhYgYy6A54fXxfiEZzHsGorw24RCEJYrj2YDjZs42%2F7YreoHQuKsxu0gR5JA4eaAICYVFJlK0C1Oc1iQLoaEim8BeB%2F3zEE58w6BkVCnCzJDHUnE7SzHhPzE76GByqxMYe61JVIMPUNciuUSDnVBbYPIRfmOD%2BIltmQNEPw48Xsp9Fdp25OCvZ1iFkjzkKAM8Lx8%2FjuNswx8qvlUjOzPMWb0w4ng2%2ByznheAwgi6dLCPSqTL0CTuagXzV8NY56YwzLQPVOBpRu%2Bjaq%2F8bAql1nnBesg0zHM%2F1E0%2FBazeuifTy8o4sbfp6JtnpNm2h9F%2Bf12G56Mtk1K9rzTibT1kDBfoDH8pYyPqcBjVH4qZCOqrAVZe5optACrB%2BY87Xcp0ELTqtQ4hXh38TrHdORt99Lj65XsursZq1uYhjwt%2FLN96wKR90Wr2V36r18gGJUT7MGINAF8%2FBTaEn6OGIBfioQN916PWA4RGI2V5p9fVKdC6mnIHXQKKm9C6knINXqNkqqnjOo827Z9m69R9MKf%2FDxIw5psvGBU7Zd%2Bo15xd7%2BbZ4zO0U9QVED9Iih2JsfzssMI75gGAr%2Bdvz6xDgLE5uMxhMB%2BpmpGJyCijSPXd8NDY2HtJa%2BUfIKNEQohUjpvbBQFwqdlwVbZ%2BEDiimfQ7hpdqcyw5TkGaaPGoDHppiehkfLJm0ypnvTSb9ONqmeJj0PVEcTUJGeniRzy7nWZv%2F%2FjySZb5ck07qQlJOk76QOv451fJ%2BRq7X1XcRhkoTEQ3IX6Y4ioQEjBER7Qim2dIAueEhifLU5aiUWyzMa8ysaUpaVseD3RvRpFDDkE1w8i6k8zcLoT1x6YZb9iIpIGNZVVNlGFFoHHQ7v0BSH9zQlWdet64j4fhb%2BqQJDuTU5pZzTqG6vsuQ66zyrGJeMEQ01ThV5GsWGZivfzUznKBFPolUgzsF10DK1O0m%2BRXfriS6OEpZfVMuggoFJCPhPpgr9l5yKyLVod%2FixNR%2FMgT4h3Jr5YDx1KuJlfr6R%2FZvW%2Fuj7yUm6PyZvHRaS51OzqZDcbmSf5eTgq6zJG0ffqdvu36IjALSTneZAnn1FU1W8exSUO82Ee0BsPLA6PavGc7qnQqsuLNteq0hjrFJMJaXbdg9cKOtOr7JxHqF4MELezyBT%2Bzr3lTU2VLk0MSe0xJpKdc05F6eXhwIJ88bzY7NDgMMZgQnFOh60CGEh4gg%2BhDwVeTGYXGl7CtGmn7ZBXW9EFiOTTjJh%2FjedZOUmM8LwjK5gleV2EpWwfo4fcXYcryspgGL6POzXJULfO%2FvWXvZT6hEUtiPsE9Q2jf4AZDZgfGN022M0Q4ycjurNkqHTE8fe7V7fdAd9UzME59UD%2FbTp%2B9cD4yArwNcJFteWgNCbM0D05ORbZsc1bNMxLatn226vYfL1DMIljrnEMaLamv2488YxjtvEUlqlLNV1Kfe4M2N58uW3deDqO5%2FOja2%2B9WzLxZhcjEmr9qsi57UlKqlysSXqayb7bUmj51V6zRxCOt3Rkxdufg0OZC0%2Fat0Ya%2F33Ms3eLNMqd7Kf6R0m%2BExMXxZnRx8WM156WCx7dcgYWpcKJJTEPC3VfC8EhS%2FWDkg5W%2FmufeXd7pa25D141VRdb%2FBe1OnNGg61R%2FBO1FBlqc%2BkhnBb%2FHuIvHjxTzasT%2F8B%3C%2Fdiagram%3E%3Cdiagram%20id%3D%225NTDSoxaS2X6YF9Ro-iN%22%20name%3D%22Page-2%22%3E7Vlbb9owFP41SN1DUULCZY%2BF0q5ap1VD0x6RiU3izeREjmlgv37HxAZygVIV6LYWJGR%2FPr6d8%2Fk7Tmh4g9niVpIk%2BgKUiUbLoYuGd91otXpeG381sMwBt%2BN0ciSUnBpsA4z4b2ZAx6BzTllaMFQAQvGkCAYQxyxQBYxICVnRbAqiOGtCQlYBRgERVfQHpyoy%2B2o7G%2FwT42FkZ3Yd0zIj1tgAaUQoZFuQN2x4Awmg8tJsMWBCO8%2F65dvnjABVvUFv8DUj8ZLDoH2ZD3bznC4tE4NHIuZmV99jxZVgFNF7smTSrFAt7bbt7iSL1ZFX06mspjK7hHlMmR7FaXj9LOKKjRIS6NYMaYZYpGYCay4WUyXhFxuAAIlIDDGa9c0cTCq2KAXyiS3l3jIbumUwY0ousaMZZh1OQ%2BhL1zI129DD8w0WbVHDs8wghpLhevCND7Fg3PgMl7pnDJ%2FbrUzGKJ4YUwWpIgghJmK4QfvFeG5s7gESE8WfTKmlOf5krqAY43xOPdHzgmk9A3MZsH12npEWIkO2lx315JBMEMUfi6s7epxb%2Fpv2fe81fW9XuSVbF3exYhJd%2BaHR6ghceZ%2FyRyyGungPRKtrnwgSB1pgcwuce8uopt8FZVh29GJ1oEnI43A9%2FkSWe5bHK9ED5krwGMXRJkfNgSnEysplo%2BXh90Y7oh9KQjnbtBkpLeordpiuPnogLkTdQJSk0ZpxWoM55tN7MmHiAVKuOMTYNuOUrghqDa4ED3XDBJSCGTYQAwRM%2B7lIyrqcoPdlWOzafdqzsUoUaI7exJqnaxFJdMtsEeqbS5Nkqd9MJNB5oO4CvcR%2BIvNC0YYkicD16m2MBUZ5PLExfknacfdnnW4p6%2FSqSadXk3Pc1qlyTk3W%2Fh%2B0yD9Qi%2FxXzQPem%2Fb9jgvamfKAX3N9PZ76GwFCbXkX%2Fbcu%2Bn75UeNQ0XdPJvqHcH%2BUX1oOJGsCXAd6%2BIieSm3M7JOyU%2BbVFhlKPGw7%2Bou4KFFuTaRdnFxTr8xJpYWxX3uaKiwtEwumUx6wZsokjpo2MzYZ5%2BXxZOW7Yz%2B17meS5xWZ9LFKJL9XJVK7eyIe9Q7h0bW%2BCJ%2BWQ7VB%2BEeJdcrbZ%2Fvvoo%2Fd1r5XSCHed5KdDjFvC8nEmjtHcZTvPuko1%2F14Rk9VLysPmOyaCF29n6JaeQ4lY%2FHLXiDu4MhrnZbq21%2FLgXclPTcHzDBd91QCitXNPwqrtq3%2FZbzhHw%3D%3D%3C%2Fdiagram%3E%3C%2Fmxfile%3E"></iframe>

Since I have serveral production web server, I also need to set 1 deployment plan for 1 server.

**Deployment project**

It's a collection of *deployment plans*.

### Deployment project summary

The deployment project summary page is a good entrypoint on understanding a deployment flow.

![image-20200913132645203](../../static/img/image-20200913132645203.png)

#### Build projects + plans + branch

**Git Flow**

I suggest all the git repositories you want to build on Bamboo are running **Git Flow**. Although this is optional, using Git Flow will make your repository more **predictable**.

The following guide is applicable to git repositories that running **Git Flow**.

**Build Project**

In bitbucket, git repositories can be grouped under a **Bitbucket project**. Therefore I follow this rule:

> 1 bitbucket project, 1 bamboo build project.

Organizing your Bitbucket build project makes your set up more **predictable**.

**Build Plan / branch**

In Bamboo, a *build plan* covers all the configurations in order to build the git repository under. The plan has a *default* branch (i.e. the **build plan**) and serveral **plan branches**.

The concept of the *build plan* may be a bit confusing. It will be easier to understand by looking at the **build dashboard**.

> Default plan: git's main branch.

### Build dashboard

![image-20200913130048805](../../static/img/image-20200913130048805.png)

Here are the highlights on columns in the dashboard:

- **Project**: Build project (1-1 mapping with the Bitbucket project)
- **Plan**: Configurations on how to build a git repository. You can have multiple *build plans* for 1 git repository. In the example above, `Audience Hub Website` and `Class Library` build plans are base on the same git repository. The difference is that I want to build a website deployment package in one plan and build a nuget package in the other.
  - **Branch logo**: You can see all *plan branches* here.
  - **Deployment plan logo**: You can see all the *deployment plans* related to this *build plan*.
- **Build**: You will notice that the build number on this column is `#19` but none of my *plan branches* is in that build number (`#4` and `#11`). The reason is that I use `develop` branch (i.e. the main branch of my repo) as the **default branch** of this build plan. `#19` is **the build number of my main branch**.

The concept of a *build plan* is a bit confusing in Bamboo. Therefore I will use 

- *build project* for the item showing at the **Project** column;
- *build plan* for the item showing at the **Plan** column;
- *default plan config* as the default configurations of a build plan;
- *plan branch / branch config* as the branch-specific configurations.

## Summary on CI/CD Set up

### CD

- 1 Bamboo *deoloyment project*, many *deployment plans*.
- 1 IIS website, 1 *deployment plan*.

### CI

- Bitbucket project <--> Bamboo *build project*
- Bitbucket git repository <--> Bamboo *build plan*
  - Main git branch <--> *Default plan config* of a build plan
  - git branch <--> *Branch config* of a build plan






![image-20200913121205640](../../static/img/image-20200913121205640.png)

### Build project and build plan

#### Build Project

In Bamboo, a *build project* may contains serveral *build plans*. Since our company also using *Bitbucket* to store source codes, I created 1 *build project* for 1 bitbucket project. This may not be the best practice but it is a **predictable** approach.

> 1 bitbucket project, 1 bamboo build project.



#### Build Plan

Assumption: all your git repositories are running **Git Flow**.

**Linked repository**

---

#### Configure git repo

Settings > Linked repositories

#### Build plan

> For traditional .NET web application, each website should has it own build plan. It is not necessary to restrict 1 build plan for 1 git repo.

- Steps to connect a repo.

It dependes on how the config is attached to the project.

e.g. .NET Framework has 1 web.config for 1 env, so may requires multiple build plans for 1 git repo.

Drawbacks: doubled the build time.

##### Build configuration

- How to start a new branch
- Child plans
- Variables: control which publish profile

https://stackoverflow.com/questions/31737080/relationship-between-solution-configuration-publish-profile-and-web-config-tra

https://www.troyhunt.com/you-deploying-it-wrong-teamcity/

#### Branch management

Assuming you are running git flow in your git repo

- Define 1 major branch for the plan's default branch (configure plan). Usually it is the `develop` branch

- Each feature branch has a auto-generated build plan. All running the same config w/ `develop`

- Some special build branch e.g. `master`, `staging`. Requires variable override and set **do not clean up**

#### Set up build stage / jobs

Who not Bamboo Specs? Bamboo server version not new enough

Custom solution: each project contains a `.bamboo` folder, and create each build step scripts in the project.

Setting up global variables: you need admin right.

