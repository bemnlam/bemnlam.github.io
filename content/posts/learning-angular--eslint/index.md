---
title: "Learning Angular: Note on Angular ESLint"
summary: A quick note on Angular ESLint
date: 2024-05-16T08:30:00-05:00
draft: false
categories: ["Dev"]
tags: ["obs", "angular", "eslint"]
thumbnail: https://cdn.dribbble.com/users/584114/screenshots/16720514/media/973820c9edfa5065c1487ac93089dd92.png
---

Here are 3 notes on ESLint warnings/errors when developing Angular app:

For each `<a>` with user interaction e.g. `(click)`, you have to define at least one **keyboard** interaction together with tab index e.g.

```html
<a 
	(click)="clickHandler" 
	(keyup.enter)="clickHandler" 
	[tabindex]="0"
>
	This is a link which allow user to click with accessbility
</a>
```

If a value is a Typescript Enum and you want to compare with a number, add `.valueOf` e.g.

```js
somePropertyWithTypeEnum.valueOf() = anIntegerYouWantToCompare;
```

Adding a hash and pass `.value` when dealing with Mat-select input handler:

```html
<mat-select 
	id="{{question.id}}" 
	formControlName="{{question.id}}"
	#selectInput
	(input)="onSearchChange(selectInput.value)"
	(change)="questionFilled()"
>
```
