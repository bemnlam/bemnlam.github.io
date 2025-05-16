---
title: "Learning React: Updating Component State in componentDidMount()"
summary: Hey I just met you and this is crazy. But here's my data so have a callback, maybe.
date: 2023-07-17T08:12:01-05:00
draft: false
categories: ["Dev"]
tags: ["react", "obs"]
thumbnail: https://images.unsplash.com/photo-1495125175509-8fddf00e56cd?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=60
---

## What `componentDidMount()` is and when will be executed?

If you want to execute the application logic when the component is mounted to the screen, you need to define the logic inside `componentDidMount()`:

> If you define the `componentDidMount` method, React will call it when your component is added *(mounted)* to the screen. This is a common place to start data fetching, set up subscriptions, or manipulate the DOM nodes.
> 

You can see more details in React’s documentation [here](https://react.dev/reference/react/Component#componentdidmount).

## Problem I was facing

I want to fetch data from an API endpoint when the component is mounted. After that, I need to update the state of this component using `this.setState()` and the value in component state will be consumed by some other functions.

However, my component state seems not updated to the latest state. This is my first version of the component:

```jsx
async componentDidMount() {
  const response = await fetch("/my-api-endpoint/resource/1");
  const parsed = await response.json();
  
	this.setState({
      data: parsed, // 1. I set state using this.setState()
  });

  const result1 = parsed.someValue; // 2. getting the correct value here
  const result2 = this.state.data.someValue // 3. getting the value before setState()
}
```

When I compared `result1` and `result2`, I found that `result2` was using the previous value stored in the state.

So, what is missing?

## Do you stuff after the state is updated

I checked the React’s documentation about the `setState` : [https://react.dev/reference/react/Component#setstate](https://react.dev/reference/react/Component#setstate)

The function is defined as this: **`setState(nextState, callback?)`**

Which means we are able to run a callback function in `setState`. Therefore I build a second version of the component:

```jsx
async componentDidMount() {
  const response = await fetch("/my-api-endpoint/resource/1");
  const parsed = await response.json();
  
	this.setState({
      data: parsed, // I set state using this.setState()
  }, () => { 
      const result2 = this.state.data.someValue // now I can get the correct value!
  });
}
```

If I try to **get the value from the state inside the callback**, I will have the latest value, which is the expected one.

In other words, remember to execute your follow-up application logic **inside the callback of `this.setState()`.**

As what I found in React’s documentation:

> `callback`: If specified, React will call the `callback` you’ve provided after the update is committed.
> 

## Conclusion

If we need to update the state inside `componentDidMount()` and use the latest state right after the state has been updated, we need to place the logic inside the callback of `this.setState()`.