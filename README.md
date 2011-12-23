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
      a[event:click=showAlert href="#"] "Show the alert"
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
element anywhere on the page.

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

In browsers which support `Object.defineProperty`, we can even set and get this
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

## Custom getters and setters

Sometimes it can be convenient to define a property with a custom getter and/or
setter method. Monkey.js mimics the `Object.defineProperty` API in ECMAScript 5
in this regard. Most often you will want to override the get method, for
example you could have a `fullName` property which combines first and last
names like so:

``` coffeescript
MyModel.property 'fullName', get: -> @get('firstName') + " " + @get('lastName')
```

You can use the `collection` shortcut to create a property which is
automatically initialized to a `Monkey.Collection`. This is convenient for
binding collections to views (see below).

``` coffeescript
MyModel.collection 'comments'
```

Internally this just calls `property` with a specialized getter and setter, you
could create these kinds of macros yourself.

## Dependencies

When a property is changed, Monkey.js automatically triggers an event called
`change:propertyName`, as well as a generic `change` event. These events are
what keeps the view up to date as the model changes. In the `fullName` property
above, changes to either `firstName` or `lastName` could require the view to be
changed, but this is not inferred automatically. You will need to explicitly
state the dependencies of the `fullName` property. This will cause it to update
it if any of the dependent properties change, just like it should. You can do
this easily like this:

``` coffeescript
MyModel.property 'fullName',
  get: -> @get('firstName') + " " + @get('lastName')
  dependsOn: ['firstName', 'lastName']
```

## Template Language

The Monkey.js template language is inspired by Slim, Jade and HAML, but not
identical to any of these.

Any view in Monkey.js must have an element as its root node. Elements may have
any number of children. Elements can have attributes within square brackets.

This is a single element with no children and an id attribute:

``` slim
div[id="monkey"]
```

Indentation is significant and is used to nest elements:

``` slim
div
  div[id="page"]
    div[id="child"]
  div[id="footer"]
```

Attributes may be bound to a model value by omitting the quotes:

``` slim
div[id=modelId]
```

Similarly text can be added to any element, this may be either
bound or unbound text or any mix thereof:

``` slim
div "Name: " name
```

## Events

Events are dispatched to the controller. The controller may choose to act on
these events in any way it chooses. The controller has a reference to both the
model, through `this.model`, and the view, through `this.view`.  These
properties will be set automatically by Monkey.js as the view is rendered. If
the view is a subview, the controller can also access its parent controller
through `this.parent`.

While you *can* access the view and thus dynamically change it from the
controller through standard DOM manipulation, you should generally avoid doing
this as much as possible. Ideally your controller should only change properties
on models, and those changes should then be dynamically reflected in the view.
This is the essence of the classical MVC pattern.

Events are bound by using the `event:name=bidning` syntax for an element's
attributes like so:

``` slim
div
  h3 "Post"
  a[href="#" event:click=like] "Like this post"
```

You can use any DOM event, such as `submit`, `mouseover`, `blur`, `keydown`,
etc. This will now look up the property `like` on your controller and call it
as a function. You could implement this as follows:

``` coffeescript
controller =
  like: -> @model.set('liked', true)
```

Note that we do not have to set `@model` ourselves, Monkey.js does this for
you.

In this example, if we have scrolled down a bit, we would jump to the start of
the page, since the link points to the `#` anchor. In many JavaScript
frameworks such as jQuery, we could fix this by returning `false` from the
event handler. In Monkey.js, returning false does nothing. Thankfully the event
object is passed into the function call on the controller, so we can use the
`preventDefault` function to stop the link being followed:

``` coffeescript
controller =
  like: (event) ->
    @model.set('liked', true)
    event.preventDefault()
```

You can use `event` for any number of things here, such as attaching the same
event to multiple targets and then figuring out which triggered the event
through `event.target`.

Preventing the default action of an event is really, really common, so having
to call `preventDefault` everywhere gets old very fast. For this reason,
Monkey.js has a special syntax in its templates to prevent the default action
without having to do any additional work in the controller. Just append an
exclamation mark after the event binding:

``` slim
div
  h3 "Post"
  a[href="#" event:click=like!] "Like this post"
```

## Binding styles

We can change the style of an element by binding its class attribute to a model
property. If possible, this is what you should do, since it separates styling
from behaviour. Sometimes however, its necessary to bind a style attribute
directly. Consider for example if you have a progress bar, whose width should
be changed based on the `progress` property of a model object.

You can use the special `style:name=value` syntax to dynamically bind styles to
elements like so:

``` slim
div[class="progress" style:width=progress]
```

Style names should be camelCased, like in JavaScript, not dash-cased, like in
CSS. That means you should write `style:backgroundColor=color`, not
`style:background-color=color`.

## Collections

Oftentimes you will want to render a collection of objects in your views.
Monkey has special syntax for collections built into its template language.
Assuming you have a model like this:

``` coffeescript
post =
  comments: [{ body: 'Hello'}, {body: 'Awesome!'}]
```

You could output the list of comments like this:

``` slim
ul[id="comments"]
  - collection comments
    li body
```

This should output one li element for each comment.

If `comments` is an instance of `Monkey.Collection`, Monkey.js will dynamically
update this collection as comments are added, removed or changed:

``` coffeescript
post =
  comments: new Monkey.Collection([{ body: 'Hello'}, {body: 'Awesome!'}])
```

## Views

It can be convenient to split parts of view into subviews. The `view` instruction
does just that:

``` slim
div
  h3 "Most recent comment"
  - view post
```

Assuming that there is a post view registered with `Monkey.registerView('post',
'...')` that view will now be rendered.

It will often be useful to use the `view` and `collection` instructions
together:

``` slim
div
  h3 "Comments"
  ul
    - collection comments
      - view comment
```

By default, the subviews will use the same controller as their parent view.
This can be quite inconvenient in a lot of cases, and we would really like to
use a specific controller for this new view.

If your controller can be instantiated with JavaScript's `new` operator, you
can use `registerController` to tell Monkey.js which controller to use for your
view. Any constructor function in JavaScript and any CoffeeScript class can be
used here. For example:

``` javascript
var CommentController = function() {};
Monkey.registerController 'comment', CommentController
```

Or in CoffeeScript:

``` coffeescript
class CommentController
Monkey.registerController 'comment', CommentController
```

Monkey.js will now infer that you want to use a `CommentController` with the
`comment` view.

# Monkey.Model

Monkey.Model allows you to map objects to resources on a server, as well as
cache them in memory and in HTML5 local storage. Of course you can bind to
instances of Monkey.Model in views and changes are reflected there dynamically.
In CoffeeScript, you can use it, simply by extending the base class Monkey.Model

``` coffeescript
class MyModel extends Monkey.Model
```

You can use the same property declarations in these models:

``` javascript
class MyModel extends Monkey.Model
  @property 'name'
```

For simplicity's sake we will refer to instances of constructors derived from
`Monkey.Model` as documents.

## Identity map

Monkey.Model assumes you have a property named `id` and that this uniquely
identifies each document. Provided that such a property exists, documents a
fetched from an in-memory cache, so that multiple queries for the same document
id return the same object. This is key to working effectively with objects
bound to views.

``` coffeescript
class Person extends Monkey.Model

person1 = new Person(id: 1, name: 'John')
person2 = new Person(id: 1, age: 23)
person2.get('name') # => 'John'
person2.get('age') # => 23
```

Here `person2` and `person1` are both variables which point to the same object,
and that object's properties are a combination of the properties assigned to
both calls of the constructor function.

## Mapping models to server resources

In order to be able to retrieve and store objects from the server store, you
will need to call the store function on the constructor function:

``` coffeescript
Person.store('/people')
```

There are two main ways of retrieving objects from the server, through `find`
and through `all`.

## Find

`find` takes and id and returns a single document, if the document has been
previously cached in memory, that in memory document is returned. If the
document has not been cached in memory, a new record with the given id is
returned immediately.

This is important to understand, Monkey.Model does not take a callback, instead
it returns something akin to a future or promise, an object with no data. Once
this document is instantiated, an AJAX request is dispatched to the server
immediately.  As soon as the AJAX request is completed, the document is updated
with the properties retrieved from the server and a change event is triggered.
If the model has been previously bound to a view, these new properties are now
reflected in the view. This architecture allows you to treat `find` as though
it were a synchronous operation, returning an object immediately, and then
immediately binding that object to a view. As soon as the data is ready, that
data will be shown in the view.

``` coffeescript
john = Person.find(1)
Monkey.render('person', john)
```

You might still want to indicate to the user that the data is currently
unavailable, this can be done through the special `loadState` property on
documents. This property can be one of `ready` when the document is ready and
loaded or `loading` while it is retrieving data from the server. You can
observe changes to the `loadState` property by listening to the
`change:loadState` event, just as you would with any other property. If a view
binds to `loadState`, changes to it are of course reflected in the view
automatically. A convenient use case for this might be to bind the `class`
attribute of an element to the `loadState` property, to indicate if there is
activity:

``` slim
div[id="person" class=loadState]
  h1 name
```

``` css
#person.loading {
  opacity: 0.5;
  background: url('spinner.gif');
}
```

You can manually trigger a refresh of the data in the document by calling the
`refresh` function. This will cause the `loadState` to change back to
`loading`.

The URL for retrieving the data for a single document is taken from the first
parameter sent to the `store` declaration, joined with the document id. So if
we have declare this:

``` coffeescript
Person.store('/people')
```

Then the URL for a document with id `1` would be `/people/1`. This follows
conventions used by many popular server side frameworks, such as Ruby on Rails.
The response is expected to have a status of 200 or 201 and contain a body with
well-formatted JSON.

If the response status is any value in the 1XX, 4XX or 5XX ranges, `loadStatus`
is changed to `error`. Additionally, the `Monkey.loadError` function is called,
which takes as arguments the document causing the error, the status code of the
response and the parsed response body, provided it contains valid JSON. By
default, this function will show an alert message, but you can assign a
different function to show errors in any way way you choose.

``` coffeescript
Monkey.loadError = (document, status, response) ->
  MyFancyModalPlugin.showModal("This didn't go so well")
```


