---
title: "🐞 Battling With Gulp and Node"
summary: Tackling the generation gap between old Gulp and young Node when building my website.
date: 2020-06-27T16:03:12+08:00
lastmod: 2020-06-27T16:28:24+08:00
draft: false
categories: ["Dev"]
tags: ["pest-control", "nodejs", "node-sass", "gulp", "gulp-sass"]
thumbnail: /posts/battling-with-gulp-and-node/thumbnail.png
---

## 😨 Problem

When I was building a website using `gulp@^3.9.0` to compile sass on the build server with Node.js v12 installed, it failed. 

Here are (part of) the errors shown in the console:

```systemverilog
error	26-Jun-2020 08:35:02	gyp ERR! node -v v12.18.0
error	26-Jun-2020 08:35:02	gyp ERR! node-gyp -v v3.8.0
error	26-Jun-2020 08:35:02	gyp ERR! not ok 
error	26-Jun-2020 08:35:02	Build failed with error code: 1
error	26-Jun-2020 08:35:05	
error	26-Jun-2020 08:35:05	npm ERR! code ELIFECYCLE
error	26-Jun-2020 08:35:05	npm ERR! errno 1
error	26-Jun-2020 08:35:05	npm ERR! node-sass@4.9.3 postinstall: `node scripts/build.js`
error	26-Jun-2020 08:35:05	npm ERR! Exit status 1
error	26-Jun-2020 08:35:05	npm ERR! 
error	26-Jun-2020 08:35:05	npm ERR! Failed at the node-sass@4.9.3 postinstall script.
error	26-Jun-2020 08:35:05	npm ERR! This is probably not a problem with npm. There is likely additional logging output above.
```

(OK I know that's not your fault, `npm`.) Here is my `package.json`:

```json
{
  "devDependencies": {
    "gulp": "^3.9.0",
    "gulp-concat": "^2.6.0",
    "gulp-minify-css": "^1.2.4",
    "gulp-rename": "^1.2.2",
    "gulp-sass": "^4.0.2",
    "gulp-sourcemaps": "*"
  }
}
```

### 😐 `node-sass`

I noticed that should be something wrong with `node-sass`, which being used in `gulp-sass`. I met this issues before and from my experience, [`node-sass` will try to download the corresponding prebuilt binary](https://stackoverflow.com/a/45807410/13742790) base on your OS or build it locally using `python`, `MSBuild`, etc... (That's why you will met lots of questions in Stack Overflow asking **`python2` not found when installing `node-sass`** ,  **what's wrong with my `node-sass`** or **I got a panic attack when dealing with `node-sass` should I consult a developer or a doctor first?**).

For this `node-sass` issue, [you can try to run this on Windows](https://hisk.io/how-to-fix-node-js-gyp-err-cant-find-python-executable-python-on-windows/):

```sh
npm install --global --production windows-build-tools
npm install node-gyp
```

Or try to delete `package-lock.json` and `node_modules` first and do a `npm install` if you can install all packages successfully on let say Mac OS but failed on Windows.

👆Those tricks saved me most of the time.

#### ~~I just want to get my css files back and you told me I have to install this and that and download node npm python ms build tools some prebuilt binaries? Are you serious, node-sass?~~

### 😑 ReferenceError: primordials is not defined

After the `node-sass` issue was solved, the build server ran the build jobs again and got these errors:

```systemverilog
error	26-Jun-2020 08:53:06	fs.js:35
error	26-Jun-2020 08:53:06	} = primordials;
error	26-Jun-2020 08:53:06	    ^
error	26-Jun-2020 08:53:06	
error	26-Jun-2020 08:53:06	ReferenceError: primordials is not defined
error	26-Jun-2020 08:53:06	    at fs.js:35:5
## ( blah blah blah ) ##
error	26-Jun-2020 08:53:06	    at Module._compile (internal/modules/cjs/loader.js:1138:30)
error	26-Jun-2020 08:53:06	    at Object.Module._extensions..js (internal/modules/cjs/loader.js:1158:10)
error	26-Jun-2020 08:53:06	    at Module.load (internal/modules/cjs/loader.js:986:32)
error	26-Jun-2020 08:53:06	    at Function.Module._load (internal/modules/cjs/loader.js:879:14)
error	26-Jun-2020 08:53:06	    at Module.require (internal/modules/cjs/loader.js:1026:19)
error	26-Jun-2020 08:53:06	    at require (internal/modules/cjs/helpers.js:72:18)
```

[This answer from Stack Overflow](https://stackoverflow.com/a/55926692/13742790) states that it is due to Node.js v12 does not compatible with Gulp v3 **and you need to upgrade Gulp to v4**. I know **I should** do that but I also know that I will meet the [Did you forget to signal async completion?](https://github.com/sindresorhus/del/issues/45) issue which also will cause an epic fail of the build **unless I re-write the gulp tasks**.

I don't want to change my `gulpfile.js` and I don't want to upgrade `gulp`. Not now.  That's why I started searching for a solution without changing any configurations of the build server as well as the gulp setup in the project.


## 😀 Solution: adding a `npm-shrinkwrap.json`

Eventually I [found a solution](https://stackoverflow.com/questions/55921442/how-to-fix-referenceerror-primordials-is-not-defined-in-node/58394828#58394828) on how to handle this "Gulp VS Node" situation. What we need is create a `npm-shrinkwrap.json` file under the same directory with `package.json`. 

The content of the json file:

```json
{
  "dependencies": {
    "graceful-fs": {
      "version": "4.2.3"
    }
  }
}
```

After that I can build the project and finish all the gulp tasks without errors 🎉. 

### 🤔 So, what's going on?

From the npm's official documentation on the [`npm-shrinkwrap` command](https://docs.npmjs.com/cli/shrinkwrap):

> This command repurposes package-lock.json into a publishable npm-shrinkwrap.json or simply creates a new one. The file created and updated by this command will then take precedence over any other existing or future package-lock.json files.

And from the documentation on the [`npm-shrinkwrap.json`](https://docs.npmjs.com/files/shrinkwrap.json):

> ... Additionally, if both `package-lock.json` and `npm-shrinkwrap.json` are present in a package root, `package-lock.json` will be ignored in favor of this file.

In other words, this file has a *higher priority* then `package-lock.json`. However, why this file can solve the build error?

#### The`fs` module

Node's `fs` module got some changes since **v11.15** which cause the `graceful-fs@^3.0.0` package does not work anymore. Unfortunately, `gulp@3.9.1` depends on  `graceful-fs@^3.0.0`. As a result, running the gulp tasks on Node.js v12 will cause the `primordials is not defined` error.

#### The fix

After we added the `npm-shrinkwrap.json`, from my understanding it locked down the version of package(s) used by the execution environment to the version stated in that file (and ignore the setup in `package-lock.json`.In the above case, the `npm-shrinkwrap.json` tells Node.js 12 use `graceful-fs@4.2.3` instead of `graceful-fs@^3.0.0`. This combination works. Meanwhile, the `gulp` package will still reference to the `package.json` and `package-lock.json` file and use the `graceful-fs@^3.0.0` package. This combination also works.



## 🎯 Conclusion

I got some build errors when using `gulp@^3.9.0` and `gulp-sass` under Node.js 12. After I delete the `package-lock.json` and  re-run `npm install`, the sass problem solved. Next, I added a `npm-shrinkwrap.json` to (temporarily) solve the incompatable issue with old gulp running on new Node.js.

#### ~~Can I call this the Node version of **dependency hell**[^1]?~~



###### 🔗 references:

- [ReferenceError: primordials is not defined の解決方法【備忘録】](https://mejiblog.com/gulp-error/)
- [Task function must be specified 解決方法【備忘録】](https://mejiblog.com/gulpfile-change/)
- [Node 12: Errors with 'primordials is not defined' #5](https://github.com/mafintosh/prebuildify-ci/issues/5#issuecomment-550867124)
- [How to fix “ReferenceError: primordials is not defined” error](https://blog.icetutor.com/how-to-fix-referenceerror-primordials-is-not-defined-error/)

[^1]: https://en.m.wikipedia.org/wiki/Dependency_hell
