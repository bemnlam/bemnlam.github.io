---
title: "VSCode tasks for Hugo"
date: 2022-02-13T14:56:15+08:00
draft: false
categories: ["Dev"]
tags: ["vscode", "hugo"]
summary: This post shows some useful VSCode tasks I set up to run and build Hugo.
cover_image: https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1000&q=80
---

This post shows some useful VSCode tasks I set up to run and build Hugo.


Create a `tasks.json` under `.vscode`. Launch `.vscode/tasks.json` and make sure that you have `version`, `tasks` and `input` :

```json
{
    "version": "2.0.0",
    "tasks": [],
    "input": []
}
```

## 1. Launch Hugo Dev Server

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Serve Drafts",
            "type": "shell",
            "command": "hugo",
            "args": ["server", "-D"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "isBackground": true,
            "options": {
                "cwd": "${workspaceFolder}/blog"
            }
        }
    ]
}
```

> Note: change the working directory when necessary. `${workspaceFolder}` is the directory contains `.vscode` folder

## 2. Launch a Mac Application

For example, I launch Mark Text in mac:

```json
{
    "label": "Launch Mark Text",
    "type": "shell",
    "command": "open",
    "args": [
        "-a",
        "\"Mark Text\"",
        "${workspaceFolder}/blog/content/posts",
        "&"
    ],
    "group": {
        "kind": "build",
        "isDefault": false
    },
    "isBackground": true,
    "options": {
        "cwd": "${workspaceFolder}/blog"
    }
}
```

## 3. Launch Script Requires User Input

For example, creating a new post requires user input the file name:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "New Post",
            "type": "shell",
            "command": "hugo",
            "args": [
                "new",
                "posts/${input:postTitlePrompt}/index.md"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "options": {
                "cwd": "${workspaceFolder}/blog"
            },
            "isBackground": true,
            "problemMatcher": []
        },
    ],
    "input": [
        {
            "id": "postTitlePrompt",
            "description": "Title of the new post",
            "type": "promptString"
        }
    ]
}
```

In this case, we have to create a `input` task to collect user's input first, and pass that value to the task.

## 4. Generate Hugo Static Site

Similar to the launc the dev task, we create a task to run `hugo build`:

```json
{
    "label": "Generate Static Site",
    "type": "shell",
    "command": "hugo",
    "group": {
        "kind": "build"
    },
    "options": {
        "cwd": "${workspaceFolder}/blog"
    }
}
```

Choose the task to run by <kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd>:

![](./img/2022-02-13-15-48-35-image.png)
