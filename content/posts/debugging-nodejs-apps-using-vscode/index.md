---
title: "Debugging Nodejs applications using VSCode"
summary: "Mastering Multi-App Debugging in VSCode for Node.js Projects"
date: 2024-09-30T08:38:57-05:00
draft: false
categories: ["Dev"]
tags: ["vscode", "nodejs", "debugging", "web", "obs"]
---

You can define suitable tasks and launch configurations to debug **multiple** Node.js application(s) in VSCode and use features like breakpoints.

If you want to skip all the details and read the final `tasks.json` and `launch.json`, see [TLDR: complete tasks.json and launch.json ](#tldr-complete-tasksjson-and-launchjson).

Assumption: we are building the apps using the following Node.js and npm versions:

```bash
❯ node -v && npm --v
v20.17.0
10.8.2
```
Also, I am using this version of VSCode:

```bash
❯ code -v
1.94.0
d78a74bcdfad14d5d3b1b782f87255d802b57511
arm64
```

## Project structure

Assuming that you have 2 Node.js projects: **vite-gaudi** and **rsbuild-frank**. Gaudi uses [Vite](https://vitejs.dev/) and Frank uses [Rsbuild](https://rsbuild.dev/) as the web bundler.

In addition, I want to define some VSCode tasks to install and run both apps.

```bash
npm create vite@latest # vite-gaudi
npm create rsbuild@latest # rsbuild-frank
```

## Create tasks.json and launch.json

```bash
mkdir .vscode
touch .vscode/tasks.json .vscode/launch.json
```

## Define tasks for pre-development

Add a `tasks` array in `tasks.json`:

```json
{
    "tasks": [
    ]
}
```

Add package install command to `vite-gaudi` under `tasks`:
```json
{
    "type": "npm",
    "script": "install",
    "path": "vite-gaudi",
    "problemMatcher": [],
    "label": "npm: install - vite-gaudi",
    "detail": "install dependencies from package"
}
```

Similarly, add the package install command under `tasks` for `rsbuild-frank`:
```json
{
    "type": "npm",
    "script": "install",
    "path": "vite-gaudi",
    "problemMatcher": [],
    "label": "npm: install - vite-gaudi",
    "detail": "install dependencies from package"
}
```

Optionally, add another command to run both install tasks at once:

```json
{
    "label": "npm: install all",
    "dependsOn": [
        "npm: install - rsbuild-frank",
        "npm: install - vite-gaudi"
    ],
    "isBackground": true
}
```

## Tasks and launch settings for development

We will need another set of tasks to run the dev mode:

### tasks.json
For `vite-gaudi`, add a new task in `tasks.json`:

```json
{
  "label": "npm: dev - vite-gaudi",
  "type": "shell",
  "hide": false,
  "command": "npm run dev",
  "options": {
    "cwd": "./vite-gaudi"
  },
  "presentation": {
    "reveal": "always"
  },
  "isBackground": true,
  "problemMatcher": {
    "owner": "typescript",
    "pattern": "$tsc",
    "fileLocation": [
      "relative",
      "${workspaceFolder}"
    ],
    "background": {
      "activeOnStart": true,
      "beginsPattern": ".*",
      "endsPattern": ".*VITE v.*"
    }
  }
}
```

For `rsbuild-frank`, add a new task in `tasks.json`:

```json
{
  "label": "npm: dev - rsbuild-frank",
  "type": "shell",
  "hide": false,
  "command": "npm run dev",
  "options": {
      "cwd": "./rsbuild-frank"
  },
  "presentation": {
      "reveal": "always"
  },
  "isBackground": true,
  "problemMatcher": {
    "owner": "typescript",
    "pattern": "$tsc",
    "fileLocation": [
      "relative",
      "${workspaceFolder}"
    ],
    "background": {
      "activeOnStart": true,
      "beginsPattern": ".*",
      "endsPattern": ".*Rsbuild v.*"
    }
  }
}

```

#### About `problemMatcher`

Configure problem matcher to detect if a task has been started and reached to a point that the debugger can be linked:

For a Vite project, we can monitor the keyword `VITE v.*`:

```bash
  VITE v5.4.8  ready in 714 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

For a Rsbuild project, we can use `Rsbuild v.*`:

```bash
> rsbuild-frank@1.0.0 dev
> rsbuild dev

  Rsbuild v1.0.9

  ➜ Local:    http://localhost:3000/
  ➜ Network:  http://192.168.2.14:3000/

start   Compiling...
ready   Compiled in 0.06 s (web)
```

When the `endPattern` has been defined, VSCode browser debugger will be launched once the console output contains the words that match with the defined pattern.

For example, if you use `.*` as the `endPattern`, the debugger will be launched whenever some text has been printed out in the console.

### launch.json

Add `version` and `configurations[]` in `launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
    ]
}
```

For `vite-gaudi`:

```json
{
    "type": "msedge",
    "request": "launch",
    "name": "Dev (vite-gaudi)",
    "url": "http://localhost:5173/",
    "webRoot": "${workspaceFolder}/vite-gaudi",
    "preLaunchTask": "npm: dev - vite-gaudi",
    "runtimeArgs": ["-inPrivate"],
    "postDebugTask": "Terminate All Tasks",
}
```

For `rsbuild-frank`:

```json
{
    "type": "msedge",
    "request": "launch",
    "name": "Dev (rsbuild-frank)",
    "url": "http://localhost:3000/",
    "webRoot": "${workspaceFolder}/rsbuild-frank",
    "preLaunchTask": "npm: dev - rsbuild-frank",
    "runtimeArgs": ["-inPrivate"],
    "postDebugTask": "Terminate All Tasks",
}
```

You can choose either `msedge` or `chrome` as the launching browser `type`.

If you wish to use Firefox as the debugging browser, you will need to install [Debugger for Firefox](https://marketplace.visualstudio.com/items?itemName=firefox-devtools.vscode-firefox-debug) and change the value of `type` into `firefox`.

Finally, create a single launch settings to launch both sites for debugging at once:

Add a task in `tasks.json` to trigger all dev scripts:
```json
{
    "label": "all:dev",
    "dependsOn": [
        "npm: dev - rsbuild-frank",
        "npm: dev - vite-gaudi"
    ],
    "presentation": {
        "reveal": "always",
        "revealProblems": "never",
        "panel": "new"
    }
}
```

Add a launch setting in `launch.json` to start the task:

```json
{
    "type": "firefox",
    "request": "launch",
    "name": "Dev (all)",
    "url": "http://localhost:5173",
    "webRoot": "${workspaceFolder}",
    "preLaunchTask": "all:dev",
    "runtimeArgs": ["-inPrivate"],
    "postDebugTask": "Terminate All Tasks",
}
```

Note: here we choose to launch the Vite app in the browser, but using the same debugging browser session you can visit and debug the Rsbuild app.

## TLDR: complete tasks.json and launch.json

The `tasks.json` contains tasks to:
- install (`npm: install - vite-gaudi`) and launch vite app (`npm: dev - vite-gaudi`)
- install (`npm: install - rsbuild-frank`) and launch rsbuild app (`npm: dev - rsbuild-frank`)
- install (`npm: install all`) and launch both apps (`all:dev`)

```json
{
  "tasks": [
    {
      "type": "npm",
      "script": "install",
      "path": "vite-gaudi",
      "problemMatcher": [],
      "label": "npm: install - vite-gaudi",
      "detail": "install dependencies from package"
    },
    {
      "type": "npm",
      "script": "install",
      "path": "rsbuild-frank",
      "problemMatcher": [],
      "label": "npm: install - rsbuild-frank",
      "detail": "install dependencies from package"
    },
    {
      "label": "npm: install all",
      "dependsOn": [
        "npm: install - rsbuild-frank",
        "npm: install - vite-gaudi"
      ],
      "isBackground": true,
      "problemMatcher": []
    },
    {
      "label": "npm: dev - vite-gaudi",
      "type": "shell",
      "hide": false,
      "command": "npm run dev",
      "options": {
        "cwd": "./vite-gaudi"
      },
      "presentation": {
        "reveal": "always"
      },
      "isBackground": true,
      "problemMatcher": {
        "owner": "typescript",
        "pattern": "$tsc",
        "fileLocation": [
          "relative",
          "${workspaceFolder}"
        ],
        "background": {
          "activeOnStart": true,
          "beginsPattern": ".*",
          "endsPattern": ".*VITE v.*"
        }
      }
    },
    {
      "label": "npm: dev - rsbuild-frank",
      "type": "shell",
      "hide": false,
      "command": "npm run dev",
      "options": {
        "cwd": "./rsbuild-frank"
      },
      "presentation": {
        "reveal": "always"
      },
      "isBackground": true,
      "problemMatcher": {
        "owner": "typescript",
        "pattern": "$tsc",
        "fileLocation": [
          "relative",
          "${workspaceFolder}"
        ],
        "background": {
          "activeOnStart": true,
          "beginsPattern": ".*",
          "endsPattern": ".*Rsbuild v.*"
        }
      }
    },
    {
      "label": "all:dev",
      "dependsOn": [
        "npm: dev - rsbuild-frank",
        "npm: dev - vite-gaudi"
      ],
      "presentation": {
        "reveal": "always",
        "revealProblems": "never",
        "panel": "new"
      }
    },
    {
      "label": "Terminate All Tasks",
      "command": "echo ${input:terminate}",
      "type": "shell",
      "problemMatcher": []
    }
  ],
  "inputs": [
    {
      "id": "terminate",
      "type": "command",
      "command": "workbench.action.tasks.terminate",
      "args": "terminateAll"
    }
  ]
}
```

Similarly, `launch.json` contains launch settngs to:
- launch and debug Vite app in browser (`Dev (vite-gaudi)`)
- launch and debug Rsbuild app in browser (`Dev (rsbuild-frank)`)
- launch and debug both apps (showing Vite app) (`Dev (all)`)

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "msedge",
            "request": "launch",
            "name": "Dev (vite-gaudi)",
            "url": "http://localhost:5173/",
            "webRoot": "${workspaceFolder}/vite-gaudi",
            "preLaunchTask": "npm: dev - vite-gaudi",
            "runtimeArgs": [
                "-inPrivate"
            ],
            "postDebugTask": "Terminate All Tasks",
        },
        {
            "type": "msedge",
            "request": "launch",
            "name": "Dev (rsbuild-frank)",
            "url": "http://localhost:3000/",
            "webRoot": "${workspaceFolder}/rsbuild-frank",
            "preLaunchTask": "npm: dev - rsbuild-frank",
            "runtimeArgs": [
                "-inPrivate"
            ],
            "postDebugTask": "Terminate All Tasks",
        },
        {
            "type": "firefox",
            "request": "launch",
            "name": "Dev (all)",
            "url": "http://localhost:5173",
            "webRoot": "${workspaceFolder}/vite-gaudi",
            "preLaunchTask": "all:dev",
            "runtimeArgs": [
                "-inPrivate"
            ],
            "postDebugTask": "Terminate All Tasks",
        }
    ]
}
```

The key to launch the browser debugging session from VSCode is to define a correct `endsPattern` in `problemMatcher` to catch the corresponding console output.

- Vite: `.*VITE v.*`
- Rsbuild: `.*Rsbuild v.*`

You can also see the complete example, including the sample Vite app, the sample Rsbuild app, together with the tasks.json and launch.json in this GitHub repository: [vscode-debugging-sample](https://github.com/bemnlam/vscode-debugging-sample).
