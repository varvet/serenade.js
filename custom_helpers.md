---
layout: default
title: Custom helpers
---

Sometimes you need to break out of the mould that Serenade has provided for
you. In order to expose arbitrary functionality in views, Serenade has custom
helpers. Using them is quite simple, just add a function which returns a DOM
element to `Serenade.Helpers`:

``` javascript
Serenade.Helpers.link = function(name, url) {
  var a = document.createElement('a');
  a.setAttribute('href', url);
  a.appendChild(document.createTextNode(name));
  return a;
};
```

You can now use this in your views like this:

```
div
  - link "Google" "http://www.google.com"
```

There is no comma separating the arguments.

You can use any library you want to generate the DOM element, and you can
return either a single element, an array of elements, a string or even
undefined from a helper.

Beware if you're using jQuery that you need to use the `get` function to
extract the actual DOM element, for example:

``` javascript
Serenade.Helpers.link = function(name, url) {
  $('<a></a>').attr('href', url).text(name).get(0);
};
```

Helpers can also receive arguments from the model. Suppose we have a model like
this:

``` javascript
var model = Serenade({
  text: 'Google',
  url: 'http://google.com/'
});
```

Given the same helper we wrote above, we could have changed our view to:

```
div
  - link @text @url
```

Now if either `text` or `url` in our model is changed, the link will also
update.

Inside the helper, you have access to a couple of things through `this`. You can
use `this.model` or `this.controller` to access the current model and controller.

Finally you have access to `this.render()` which is a function that renders any
children of this instruction. For example if we wanted to create a block helper
for links like this:

```
div
  - link "http://www.google.com"
    span "Link: " @name
    @caption
```

You could implement the helper like this:

``` javascript
Serenade.Helpers.link = function(url) {
  var a = document.createElement('a');
  a.setAttribute('href', url);
  a.appendChild(this.render());
  return a;
};
```

`render` takes the model as its first and the controller as its second
argument. You can call `render` multiple times, possibly sending in different
models and/or controllers for each invocation. Render returns a document
fragment, so like in the example above, it is no problem for a helper have
multiple direct children.

