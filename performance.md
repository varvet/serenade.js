---
layout: default
title: Performance
---

Serenade is built to be performant and memory safe. That being said, there are
a few things you can keep in mind, primarily when building larger applications,
which can greatly improve the performance of your applications and prevent
pesky memory leaks.

## Removing views

When you render a view, Serenade adds listener functions to your model which
keep the view in sync if the model changes. Unfortunately, if these listeners
are not removed properly, they might keep any DOM elements which they reference
from being garbage collected. This leads to memory leaks. Serenade has your
back and in most cases you don't have to worry about this, because Serenade
will do the right thing.

There is however one situation where you have to be a bit careful. If you want
to remove a view you have inserted into the DOM yourself, you must remove it
explicitly, rather than manipulating the DOM manually.

For example, this is bad:

``` javascript
target = document.querySelector("#something")
view = Serenade.view('h1 "Hello " @name').render({ name: "Jonas" })
target.appendChild(view)
// ... later ...
target.innerHTML = "" // don't do this!
$(target).empty() // or something like this with jQuery
```

You may have noticed that `render` actually returns a [DocumentFragment][frag].
This DocumentFragment has been extended with a non-standard method called
`remove`. Calling this method safely removes the view from the DOM without
causing memory leaks.

``` javascript
target = document.querySelector("#something")
view = Serenade.view('h1 "Hello " @name').render({ name: "Jonas" })
target.appendChild(view)
// ... later ...
view.remove() // this is correct!
```

In general you should be very careful about manually manipulating any of the
DOM elements rendered by Serenade.

## Cleaning up model custom bindings

In some cases you might add listeners to model properties manually. If you do
this, make sure to remove them when you no longer need them, especially if this
property or any property which depends on depends on values in other objects.
Failing to remove listeners you have added might keep objects from being
garbage collected and thus cause memory leaks.

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
});
```

The random number will often be the same number, but since we've (for whatever
contrived reason) have wrapped the number in an object, Serenade will trigger a
change event anyway, since two objects will never be equal. This could of
course trigger an expensive DOM operation. By defining the `change` option, we
can make sure this does not happen.

In other cases, changes do occur frequently, but perhaps more frequently than
desired. Sometimes more frequently than the human eye could perceive. Serenade
gives you control over how frequently events are triggered. For example if you
want events to be fired at most once every 250ms, you could define a property
like this:

``` javascript
Serenade.defineProperty(model, "updatesFrequently", { timeout: 250 });
```

Serenade also allows you to hook into `requestAnimationFrame`, so that frequent
changes to a property can be animated smoothly.

Before you can do this though, you'll need to shim `requestAnimationFrame`
since it isn't available in any browsers without a vendor prefix yet. See the
MDN docs for [requestAnimationFrame][request] and
[cancelAnimationFrame][cancel].

Once you've done this, you can now specify the `animate` option like this:

``` javascript
Serenade.defineProperty(model, "updatesFrequently", { animate: true });
```

[frag]: https://developer.mozilla.org/en-US/docs/Web/API/DocumentFragment
[request]: https://developer.mozilla.org/en-US/docs/Web/API/window.requestAnimationFrame
[cancel]: https://developer.mozilla.org/en-US/docs/Web/API/window.cancelAnimationFrame
