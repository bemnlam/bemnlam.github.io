---
title: "🐞 GitVersioning: 'ThisAssembly' Is Inaccessible Due to Its Protection Level"
summary: I can't use 'ThisAssembly' in my .NET MVC project. Here's why.
date: 2020-06-25T17:10:24+08:00
lastmod: 2020-06-28T11:10:24+08:00
draft: false
categories: ["Dev"]
tags: ["pest-control", "csharp", ".NET", "nuget"]
thumbnail: https://i.insider.com/5593f5cc6bb3f7ac51d8d3cf
---

## 😨 Problem

After I installed the **[Nerdbank.GitVersioning](https://www.nuget.org/packages/Nerdbank.GitVersioning)** Nuget package in my .NET MVC app, the following error came out when I want to get the version using `ThisAssembly.AssemblyInformationalVersion`:

```bash
error CS0122: 'ThisAssembly' is inaccessible due to its protection level
```

I tried to install the package across all the projects in the same solution. It didn't work.

I tried to uninstall and re-ininstall the package. It didn't work.

## 😀 Solution

### .csproj

Turns out there is something missing in my `.csproj` file. I missed an `<Import>` tag at the end of the file, just before the `</Target>` tag:

```xml
<Import Project="..\packages\Nerdbank.GitVersioning.3.1.91\build\Nerdbank.GitVersioning.targets" Condition="Exists('..\packages\Nerdbank.GitVersioning.3.1.91\build\Nerdbank.GitVersioning.targets')" />
```

And in the `EnsureNuGetPackageBuildImports` target, add the following line:

```xml
<Error Condition="!Exists('..\packages\Nerdbank.GitVersioning.3.1.91\build\Nerdbank.GitVersioning.targets')" Text="$([System.String]::Format('$(ErrorText)', '..\packages\Nerdbank.GitVersioning.3.1.91\build\Nerdbank.GitVersioning.targets'))" />
```

In addition, the 1st `<PropertyGroup>` should contain a pair of  `NuGetPackageImportStamp` tag:

```xml
<NuGetPackageImportStamp>
</NuGetPackageImportStamp>
```

### `AssemblyInfo.cs`

I also removed the following lines in `Properties/AssemblyInfo.cs`:

```c#
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]
```

### `version.json`

At the root directory of the **project**, I added a `version.json` file with the following content:

```json
{
  "$schema": "https://raw.githubusercontent.com/dotnet/Nerdbank.GitVersioning/master/src/NerdBank.GitVersioning/version.schema.json",
  "version": "1.0.0"
}
```

After that, `ThisAssembly` is back and I can read the git version info successfully.



###### 🔗 references:
- https://github.com/dotnet/Nerdbank.GitVersioning/blob/master/doc/dotnet.md
- https://github.com/dotnet/Nerdbank.GitVersioning/issues/449
- https://github.com/dotnet/Nerdbank.GitVersioning/issues/404

###### 🖼 cover image: [Grace Hopper’s operational logbook for the Harvard Mark II computer](https://www.businessinsider.com.au/harvard-mark-i-grace-hopper-bug-2015-7)