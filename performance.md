---
layout: default
title: Performance
---

Serenade is built to be performant and memory safe. That being said, there are
a few things you can keep in mind, primarily when building larger applications,
which can greatly improve the performance of your applications and prevent
pesky memory leaks.

## Memory safe model listeners

Serenade works extensively with event listeners under the hood. When a model
changes, it automatically propagates its changes to the view. In order to be
able to do this, the view adds event listeners to the model. Let's illustrate
this with an example:

``` javascript
jonas = Serenade(name: "Jonas")
Serenade.view('h1 "Hello " @name').render(jonas)
```

This will create a DOM element which reacts to changes to the `jonas` model.
Serenade adds a listener to the jonas model, in effect, it's going to do
something like the following pseudo code:

``` javascript
jonas.name_property.bind(function(value) {
  textNode.nodeValue = value;
});
```

What happens when the `textNode` element that this references no longer exists
on the page? Nothing actually. Unfortunately, there's a more insidious problem
here. Since the listener we added references the textNode, your brower's
garbade collector can never collect it. The garbage collector can only collect
objects which no longer have any references to it. Since JavaScript lacks a
feature called "weak references" we have no other way than to clean it up by
hand.

The good news is that Serenade does this for you in almost all cases. There are
however a few places where you need to watch out!

## Inserting views into the DOM directly.

Serenade assumes that you are not going to remove any views you have inserted
into the DOM yourself. If you ever need to remove a view you've inserted into
the DOM, Serenade has a special way of doing this which also cleans up any event
handlers:

``` javascript
jonas = Serenade(name: "Jonas");
view = Serenade.view('h1 "Hello " @name').compile(jonas);
document.body.appendChild(view.fragment); // append it
view.remove(); // remove it
```

Note that we called `compile` instead of `render` on the view, and we got back
a special object, which has a property called `fragment` which returns a
document fragment and also a method called `remove`, which safely disposes of
the view.

## Custom helpers which render views

Some custom helpers might want to render view, for example, this contrived
example:

``` javascript
Serenade.Helpers.greeting = function() {
  // don't do this!!!
  Serenade.view('h1 "Hello " @name').render(this.model, this.controller)
};
```

This too can cause memory leaks, because the returned view might have to be
removed at some point. Consider for example that `greeting` would have been
used in the following view:

```
- if @doGreeting
  - greeting
- else
  "no greeting for you!"
```

Whenever `@doGreeting` changes from `true` to `false`, a model listener
leaks.

This problem is easily fixed like this:

``` javascript
Serenade.Helpers.greeting = function() {
  Serenade.view('h1 "Hello " @name').compile(this.model, this.controller)
};
```

Again, using `compile` fixes the memory leak.

## Cleaning up model custom bindings

If you have bound listeners to models, you need to make sure that they are
removed properly.

## Caching properties

Some computed properties might be expensive for example:

``` javascript
Serenade.defineProperty(model, "costly", {
  get: function() { return costlyCalculation() },
}
```

You can cache the value of these properties, so that accessing these often
does not incur the cost of the calculation every time:

``` javascript
Serenade.defineProperty(model, "costly", {
  cache: true,
  get: function() { return costlyCalculation() },
}
```

If the property has dependencies and any dependency changes, the cache is
invalidated automatically.

## Controlling when change events are fired

Updating the DOM is always expensive. That's why it's a good idea to avoid
updating the DOM too frequently. If a view listens to a model property, it will
update whenever the model property changes. Sometimes though, a change might be
unnecessary. Serenade allows you to configure when a change event is triggered:

``` javascript
Serenade.defineProperty(model, "randomNumber", {
  change: function(before, after) { return before.value === after.value },
  get: function() { return { value: Math.round(Math.random() * 3) } }
}
```

The random number will often be the same number, but since we've (for whatever
contrived reason) have wrapped the number in an object, Serenade will trigger a
change event anyway, since two objects will never be equal. This could of
course trigger an expensive DOM operation. By defining the `change` option, we
can make sure this does not happen.

## Buffering change events of properties

Sometimes a property might receive many change events in a short period of time,
in that case, it might not be desirable for each of these changes to trigger
a separate change event, but rather we'd like to wait for these changes to stop
and only then issue a change event. `timeout` allows you to just that.
