# Monkey.js

Monkey.js is yet another MVC client side JavaScript framework. Why do we
indulge in recreating the wheel? We believe that Monkey.js more closely follows
the ideas of classical MVC than competing frameworks and has a number of other
advantages as well:

* Super pretty, powerful yet logic-less template language
* Data bindings keep your views up-to-date without any extra work
* Powerful caching and synchronization features
* Absolutely no dependencies, everything works without jQuery
* No need to inherit from base classes anywhere (though you can if you want)

## Architecture

In Monkey.js you define templates and render them, handing in a controller and
a model to the template. Monkey.js then handles getting values from the model
and updating them dynamically as the model changes, as well as dispatching
events to the controller when they occur. Templates are "logic-less" in that
they do not allow the execution of any code. Monkey.js is built around its
template engine, so unfortunately you do not have a choice as to the template
language.

Monkey.js also bundles a powerful abstraction for talking with RESTful
services, you can use Monkey.Model to persist and retrieve data, as well as
cache data in local storage.

## A simple example

Let us start off by creating a model and controller:

``` coffeescript
controller = { showAlert: -> alert('Alert!!!') }
model = { name: 'Jonas' }
```

As you can see, these are just normal JavaScript objects. Monkey.js does not
force you to use any kind of base object or class for models and controllers.

Let us now register a view, we are using Monkey.js's own template language here:

``` coffeescript
Monkey.registerView 'test', '''
  div[id="hello-world"]
    h1 name
    p
      a[click=showAlert href="#"] "Show the alert"
'''
```

Once we have a view registered, we can render it using `Monkey.render`, passing
in the model and controller we created before:

``` coffeescript
result = Monkey.render('test', model, controller)
```

The result we are getting back is just a regular DOM element. This element has
all events already attached, so you can just insert it into the DOM anywhere,
and you're good to go. Using standard DOM methods, we could do that like this:

``` coffeescript
window.onload = ->
  document.body.appendChild(result)
```

If you're using jQuery, you can use jQuery's `append` function to append the
document anywhere on the page.

``` coffeescript
$ -> $('body').append(result)
```

This example is written in CoffeeScript for easier readability, but there is
nothing stopping you from writing this in plain JavaScript as well.

## Dynamic properties

Unfortunately JavaScript does not make it possible to track changes to
arbitrary objects, so in order to update the view automatically as the model
changes, we will have to add some functionality to it. Thankfully this is quite
simple:

``` coffeescript
model = {}
Monkey.extend(model, Monkey.Properties)
model.property 'name'
```

Now we can set and get the name property using the `set` and `get` methods:

``` coffeescript
model.set('name', 'Peter')
model.get('name')
```

In browser which support Object.defineProperty, we can even set and get this
property directly, like so:

``` coffeescript
model.name = 'Peter'
model.name
```

Note that Opera and IE8 and below do *not* support this, so you might want to
refrain from using this syntax. Further note that it is not strictly necessary
to call `model.property 'name'` unless you plan on using this feature, `get`
and `set` work fine without the property being declared.

If your model is a constructor, you might want to add the properties to its
prototype instead:

``` javascript
var MyModel = function(name) {
  this.set('name', name);
};
Monkey.extend(MyModel.prototype, Monkey.Properties)
```

Or in CoffeeScript:

``` coffeescript
class MyModel
  Monkey.extend(@prototype, Monkey.Properties)
```

## Monkey.Model

It can be quite convenient to use any old JavaScript object as a model, but
sometimes we require more powerful abstractions. Monkey offers a base for
building objects which is quite powerful. You can use it like this:

``` coffeescript
class MyModel extends Monkey.Model
```

You can use the same property declarations in these models:

``` javascript
MyModel.property('name')
```
