# Monkey.js

Monkey.js is yet another MVC client side JavaScript framework. Why do we indulge in recreating the wheel? We believe that Monkey.js more closely follows the ideas of classical MVC than competing frameworks and has a number of other advantages as well:

* Super pretty, powerful yet logic-less template language
* Data bindings keep your views up-to-date without any extra work
* Powerful caching and synchronization features
* Absolutely no dependencies, everything works without jQuery
* No need to inherit from base classes anywhere (though you can if you want)

## Architecture

Monkey.js consists of two separate components:
* A template engine
* An object-to-service mapper

# Template Engine

Monkey.js derives its power from its template engine. Unlike other frameworks, Monkey.js is oppinionated, and you do not have a choice as to how to construct your templates. You can think of all of Monkey.js as a really advanced template engine. This is mirrored in the fact that you instruct a template to render, and hand it a controller and model to bind to, in return you get a DOM element, which you can inject anywhere on your page. Unlike Rails or Backbone.js for example, the controller does not render the view, its sole responsibility is responding to interaction from the user.

## A simple example

This is a very simple example:

``` coffeescript
# register a view
Monkey.registerView 'test', '''
  div[id="hello-world"]
    h1 name
    p
      a[click=showAlert href="#"] "Show the alert"
'''

# set up model and controller
controller = { showAlert: -> alert('Alert!!!') }
model = { name: 'Jonas' }

# render the view
result = Monkey.render('test', model, controller)

# Now insert it into the page
window.onload = ->
  document.body.appendChild(result)
```

This example is written in CoffeeScript for easier readability, but there is nothing stopping you from writing this in plain JavaScript as well.

You may notice that model and controller are just plain JavaScript objects, this is the core philosophy of Monkey.js, you should never have to inherit from any base class.

If we want the view to update automatically as the model changes, we will have to add some functionality to our model. Thankfully this is quite simple:

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

In browser which support Object.defineProperty, we can even set and get this property directly, like so:

``` coffeescript
model.name = 'Peter'
model.name
```

Note that Opera and IE8 and below do *not* support this, so you might want to refrain from using this syntax.

If your model is a constructor, you might want to add the properties to its prototype instead:

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

It can be quite convenient to use any old JavaScript object as a model, but sometimes we require more powerful abstractions. Monkey offers a base for building objects which is quite powerful. You can use it like this:

``` coffeescript
class MyModel extends Monkey.Model
```

You can use the same property declarations in these models:

``` javascript
MyModel.property('name')
```
