---
layout: default
title: Controllers
---

Controllers may either be normal objects, or functions. If the controller is
given as a function, it is called as a constructor (using the `new` operator)
and passed the model as an argument. So a controller could be set up like this:

``` javascript
var PostController = function(post) {
  this.post = post;
};

PostController.prototype.favourite = function() {
  this.post.favourite = true;
};

Serenade.render("post", post, PostController);
```

When the controller is a constructor, it is initialized *before* the view is
rendered. This means that it is impossible to access the view from the
constructor function. This gives you the opportunity of doing whatever you need
before rendering happens.

For both controllers passed as functions and as regular objects, if they
implement a method called `loaded` then it is called with the root element of
the view and the model after the view has rendered:

``` javascript
var PostController = function(post) {};

PostController.prototype.loaded = function(view, model) {
  new Datepicker(view.querySelector("#date"));
};

Serenade.render("post", post, PostController);
```

As you can see, the loaded function makes it possible to bind events to views
which fall outside the normal flow of Serenade views and events.

If you're using CoffeeScript you can use classes for your controllers:

``` coffeescript
class PostController
  constructor: (@post) ->
  loaded: (view) -> new Datepicker(view.querySelector("#date"))
  favourite: -> @post.favourite = true

Serenade.render("post", post, PostController)
```

## Events

Events are bound and given a name in the view. When the event is triggered,
Serenade looks up the property with the name of the event on the controller and
calls it as a function. Such a function is called an `action`.

Actions receive as parameters the element that the event was bound
to, the model, and the event object itself.

Since the action has access to the DOM element, you can interact with the DOM
from your controller actions. Be careful with modifying the DOM though. Ideally
you would just update properties on model objects and have the view
automatically reflect those changes.

Events are bound by using the `event:name=binding` syntax for an element's
attributes like so:

```
div
  h3 "Post"
  a[href="#" event:click=like] "Like this post"
```

You can use any DOM event, such as `submit`, `mouseover`, `blur`, `keydown`,
etc. This will now look up the property `like` on your controller and call it
as a function. You could implement this as follows:

``` javascript
var controller = {
  like: function(element, model) { model.liked = true; }
};
```

In this example, if we have scrolled down a bit, we would jump to the start of
the page, since the link points to the `#` anchor. In many JavaScript
frameworks such as jQuery, we could fix this by returning `false` from the
event handler. In Serenade.js, returning false does nothing. Thankfully the event
object is passed into the function call on the controller, so we can use the
`preventDefault` function to stop the link being followed:

``` javascript
var controller = {
  like: function(element, model, event) {
    model.liked = true;
    event.preventDefault():
  }
};
```

Preventing the default action of an event is really, really common, so having
to call `preventDefault` everywhere gets old very fast. For this reason,
Serenade.js has a special syntax in its templates to prevent the default action
without having to do any additional work in the controller. Just append an
exclamation mark after the event binding:

```
div
  h3 "Post"
  a[href="#" event:click=like!] "Like this post"
```

