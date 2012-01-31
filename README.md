# Serenade.js

Serenade.js is yet another MVC client side JavaScript framework. Why do we
indulge in recreating the wheel? We believe that Serenade.js more closely follows
the ideas of classical MVC than competing frameworks and has a number of other
advantages as well:

* Super pretty, powerful yet logic-less template language
* Data bindings keep your views up-to-date without any extra work
* Powerful caching features
* Absolutely no dependencies, everything works without jQuery
* No need to inherit from base classes anywhere (though you can if you want)

## Important Note!

This is an ongoing, alpha level project. Be prepared that the API might change
and bugs might occur. Currently, versions of Internet Explorer below IE8 are
not supported. In the future, IE7 will be supported. Support for IE6 is not
planned.

## Download

Download here: https://github.com/elabs/serenade.js/downloads

## Architecture

In Serenade.js you define templates and render them, handing in a controller
and a model to the template. Serenade.js then handles getting values from the
model and updating them dynamically as the model changes, as well as
dispatching events to the controller when they occur. Templates are
"logic-less" in that they do not allow the execution of any code, instead they
declaratively define what data to bind to and which events to react to and how.

## Introduction

The hello world example:

``` javascript
var element = Serenade.view('h1 "Hello World"').render();
document.body.appendChild(element);
```

As you can see we are rendering a view, which returns a DOM element. We then
insert this element into the body. Let's throw in some data:

``` javascript
var model = { name: "Jonas" };

var element = Serenade.view('h1 "Hello " @name').render(model);
document.body.appendChild(element);
```

The data from the model object is interpolated into the template. The model is
always the first argument to `render`. We'll add a controller to receive
events:

``` javascript
var controller = { say: function() { alert("Hello " + this.model.name) } };
var model = { name: "Jonas" };

var element = Serenade.view('button[event:click=say] "Say hello"').render(model, controller)
document.body.appendChild(element)
```

The controller is the second argument to `render`. You can bind events in the
view, which will call the function on the controller as needed.

As you can see, model and controller are just regular JavaScript objects, with
no special logic.

We will probably want to save the view so that we can render it multiple times,
just give it a name:

``` javascript
Serenade.view('hello_world', 'h1 "Hello World"');
```

And you can render it later, through the global `Serenade.render` function:

``` javascript
var element = Serenade.render('hello_world', model, controller);
document.body.appendChild(element);
```

There are more advanced examples in the `examples` folder, check out a live
demo of those examples running [here](http://serenade.herokuapp.com/). There is
also an implementation of the [todomvc app using
Serenade.js](https://github.com/elabs/serenade_todomvc).

## Dynamic properties

Unfortunately JavaScript does not make it possible to track changes to
arbitrary objects, so in order to update the view automatically as the model
changes, we will have to add some functionality to it. Thankfully this is quite
simple:

``` javascript
var model = {};
Serenade.extend(model, Serenade.Properties);
model.property('name');
```

Now we can set and get the name property using the `set` and `get` functions:

``` javascript
model.set('name', 'Peter');
model.get('name');
```

In browsers which support `Object.defineProperty`, we can even set and get this
property directly, like so:

``` javascript
model.name = 'Peter';
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
Serenade.extend(MyModel.prototype, Serenade.Properties)
```

Or in CoffeeScript:

``` coffeescript
class MyModel
  Serenade.extend(@prototype, Serenade.Properties)
```

## Custom getters and setters

Sometimes it can be convenient to define a property with a custom getter and/or
setter function. Serenade.js mimics the `Object.defineProperty` API in
ECMAScript 5 in this regard. Most often you will want to override the get
function, for example you could have a `fullName` property which combines first
and last names like so:

``` javascript
MyModel.property('fullName', {
  get: function() { return this.get('firstName') + " " + this.get('lastName') }
});
```

You can use the `collection` shortcut to create a property which is
automatically initialized to a `Serenade.Collection`. This is convenient for
binding collections to views (see below).

``` javascript
MyModel.collection('comments');
```

Internally this just calls `property` with a specialized getter and setter.

## Format

Sometimes you want the value of the property to appear differently in a view
than when handling the property internally. Consider a property representing a
monetary value. You would want to handle this as an integer in the model, but
the view should show it properly formatted, with currency information and so
on. You can use the `format` option for this.

``` javascript
MyModel.property('price', { format: function(value) { return "€ " + value } });
```

To retrieve a formatted value, call `format('price')`.

## Dependencies

When a property is changed, Serenade.js automatically triggers an event called
`change:propertyName`, as well as a generic `change` event. These events are
what keeps the view up to date as the model changes. In the `fullName` property
above, changes to either `firstName` or `lastName` could require the view to be
changed, but this is not inferred automatically. You will need to explicitly
state the dependencies of the `fullName` property. This will cause it to update
it if any of the dependent properties change, just like it should. You can do
this easily like this:

``` javascript
MyModel.property('fullName', {
  get: function() { return this.get('firstName') + " " + this.get('lastName') },
  dependsOn: ['firstName', 'lastName']
});
```

## Template Language

The Serenade.js template language is inspired by Slim, Jade and HAML, but not
identical to any of these.

Any view in Serenade.js must have an element as its root node. Elements may
have any number of children. Elements can have attributes within square
brackets.

This is a single element with no children and an id attribute:

``` slim
div[id="serenade"]
```

You can use a short form similar to a CSS selector:

``` slim
div#serenade.some-class
```

You can omit the element name, which will create div elements:

``` slim
#serenade.some-class
```

Indentation is significant and is used to nest elements:

``` slim
#page
  article#content
    #child
  footer
```

Attributes may be bound to a model value by prefix the name with `@`:

``` slim
div[id=@modelId]
```

Similarly text can be added to any element, this may be either bound or unbound
text or any mix thereof:

``` slim
div "Name: " @name
```

## Events

Events are dispatched to the controller. The controller may choose to act on
these events in any way it chooses. The controller has a reference to both the
model, through `this.model`, and the view, through `this.view`. These
properties will be set automatically by Serenade.js as the view is rendered. If
the view is a subview, the controller can also access its parent controller
through `this.parent`.

While you *can* access the view and thus dynamically change it from the
controller through standard DOM manipulation, you should generally avoid doing
this as much as possible. Ideally your controller should only change properties
on models, and those changes should then be dynamically reflected in the view.
This is the essence of the classical MVC pattern.

Events are bound by using the `event:name=binding` syntax for an element's
attributes like so:

``` slim
div
  h3 "Post"
  a[href="#" event:click=like] "Like this post"
```

You can use any DOM event, such as `submit`, `mouseover`, `blur`, `keydown`,
etc. This will now look up the property `like` on your controller and call it
as a function. You could implement this as follows:

``` javascript
var controller = {
  like: function() { this.model.set('liked', true) }
};
```

Note that we do not have to set `this.model` ourselves, Serenade.js does this for
you.

In this example, if we have scrolled down a bit, we would jump to the start of
the page, since the link points to the `#` anchor. In many JavaScript
frameworks such as jQuery, we could fix this by returning `false` from the
event handler. In Serenade.js, returning false does nothing. Thankfully the event
object is passed into the function call on the controller, so we can use the
`preventDefault` function to stop the link being followed:

``` javascript
var controller = {
  like: function(event) {
    this.model.set('liked', true)
    event.preventDefault()
  }
};
```

You can use `event` for any number of things here, such as attaching the same
event to multiple targets and then figuring out which triggered the event
through `event.target`.

Preventing the default action of an event is really, really common, so having
to call `preventDefault` everywhere gets old very fast. For this reason,
Serenade.js has a special syntax in its templates to prevent the default action
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
div[class="progress" style:width=@progress]
```

Style names should be camelCased, like in JavaScript, not dash-cased, like in
CSS. That means you should write `style:backgroundColor=color`, not
`style:background-color=color`.

## Collections

Oftentimes you will want to render a collection of objects in your views.
Serenade has special syntax for collections built into its template language.
Assuming you have a model like this:

``` javascript
var post = {
  comments: [{ body: 'Hello'}, {body: 'Awesome!'}]
};
```

You could output the list of comments like this:

``` slim
ul[id="comments"]
  - collection @comments
    li @body
```

This should output one li element for each comment.

If `comments` is an instance of `Serenade.Collection`, Serenade.js will dynamically
update this collection as comments are added, removed or changed:

``` javascript
var post = {
  comments: new Serenade.Collection([{ body: 'Hello'}, {body: 'Awesome!'}])
};
```

## Views

It can be convenient to split parts of views into subviews. The `view`
instruction does just that:

``` slim
div
  h3 "Most recent comment"
  - view "post"
```

Assuming that there is a post view registered with `Serenade.view('post',
'...')` that view will now be rendered.

It will often be useful to use the `view` and `collection` instructions
together:

``` slim
div
  h3 "Comments"
  ul
    - collection @comments
      - view "comment"
```

By default, the subviews will use the same controller as their parent view.
This can be quite inconvenient in a lot of cases, and we would really like to
use a specific controller for this new view.

If your controller can be instantiated with JavaScript's `new` operator, you
can use `controller` to tell Serenade.js which controller to use for your
view. Any constructor function in JavaScript and any CoffeeScript class can be
used here. For example:

``` javascript
var CommentController = function() {};
Serenade.controller('comment', CommentController);
```

Or in CoffeeScript:

``` coffeescript
class CommentController
Serenade.controller 'comment', CommentController
```

Serenade.js will now infer that you want to use a `CommentController` with the
`comment` view.

# Serenade.Model

Serenade.Model provides a more fully featured starting point for creating
feature rich model objects. You can of course bind to instances of
`Serenade.Model` in views and changes are reflected there dynamically.

In CoffeeScript, you can use it, simply by extending the base class
Serenade.Model

``` coffeescript
class MyModel extends Serenade.Model
```

In JavaScript you can use the `extend` function on Serenade.Model, you need to
pass the name of the class as the first parameter:

``` javascript
var MyModel = Serenade.Service.extend('MyModel');
```

Note that in following with JavaScript conventions, you need to define instance
methods on the prototype of the new model:

``` javascript
var MyModel = Serenade.Service.extend('MyModel');
MyModel.prototype.someInstanceMethod = function() { … };
```

You can use the same property declarations in these models:

``` javascript
MyModel.property('name');
```

For simplicity's sake we will refer to instances of constructors derived from
`Serenade.Model` as documents.

## Identity map

NOTE: Due to a bug in CoffeeScript, this is currently broken. The bug is fixed
on CoffeeScript master and the next release should work as expected.

Serenade.Model assumes you have a property named `id` and that this uniquely
identifies each document. Provided that such a property exists, documents are
fetched from an in-memory cache, so that multiple queries for the same document
id return the same object. This is key to working effectively with objects
bound to views.

``` javascript
var Person = Serenade.Service.extend('Person');

person1 = new Person(id: 1, name: 'John');
person2 = new Person(id: 1, age: 23);
person2.get('name'); # => 'John'
person2.get('age'); # => 23
```

Here `person2` and `person1` are both variables which point to the same object,
and that object's properties are a combination of the properties assigned to
both calls of the constructor function.

## Serialization

It is often useful to be able to serialize objects to a simple key/value
representation, suitable for transfer in JSON format, and to unserialize it
from such a format.

`Serenade.Model` includes some facilities to make this process easier. You will
have to tell the model what parameters to serialize, and how. You can do this
easily by setting the `serialize` option on your properties, like so:

``` javascript
Person.property('name', { serialize: true });
```

Often, you will want to specify a specific name to serialize a property as,
some server-side languages have different naming conventions than JavaScript
does for example, so you might want to translate these properties:

``` javascript
Person.property('firstName', { serialize: 'first_name' });
```

If you declare a property serializable like so, not only will the `serialize`
function use the underscored form, an alias for the setter function will also
be added, so that you can do `set('first_name', 'Jonas')`. This is especially
useful when providing JSON data from the server, as it will allow you to use
the correct naming conventions both on the server and client.

## Associations

You can declare that a model has an associated model. For example, each comment
might belong to a post, you can declare this like this:

``` javascript
Comment.belongsTo('post', { as: function() { return window.Post } });
```

Adding a `belongsTo` association will automatically create an id column, which
will be kept in sync with the associated object. In this example, assigning an
id to `postId` will find that post and assign it to the `post` property, vice
versa if you assign a document to the `post` property, its id will be
exctracted and assigned to `postId`.

The optional property `as` defines a constructor to be used for this property.
When specified, you can assign any JavaScript object to the property and it
will automatically be run through the constructor function. Note that the
constructor is wrapped in a function call, so that we can defer resolution
until later. This is so circular dependencies can work as expected.

(I don't particularly like this syntax, if you have a better idea, please tell
me!)

In the inverse situation, where a post has many comments, you can use the
`hasMany` declaration. This will add a collection of comments, which you can
manipulate however you choose. Changes to this comments collection will be
reflected in the `commentsIds` property.

``` javascript
Post.hasMany('comments', { as: function() { return window.Comment } });
```

If the `constructor` property is omitted from either declaration, then the
associated documents will be plain objects instead.

## Serializing associations

Both types of associations can be serialized by declaring `serialize: true` on
them, just like normal properties. In that case, the entire associated
documents will be serialized. This may not be the desired behaviour, you may
want to only serialize the id or ids of the associated document(s). In that
case, you can declare the associations like this:

``` javascript
Post.hasMany('comments', { constructor: 'Comment', serializeIds: true });
Comment.belongsTo('post', { constructor: 'Post', serializeId: true });
```

All of these declarations can of course also take a string so that the
association is serialized under another name:

``` javascript
Comment.belongsTo('post', { constructor: 'Post', serializeId: 'post_id' });
```

## HTML5 Local Storage

Serenade.Model can transparently cache objects in HTML5 local storage. Working
with local storage is identical to working with the in-memory identity map. The
only difference is that you can control when an individual document is cached
in local storage. You can do this by setting `localStorage` on the model:

``` javascript
Post.localStorage = true;
```

The possible values for `localStorage` are `false` (the default), `true` and
its alias `set`, which will cache the document to local storage as it is
updated through setter functions, and finally `save` which will only cache the
document if `save` is called explicitely.

## Express.js support

Serenade.js provides the expected api which allows it to be used from inside
express.js, you could use this API for other JavaScript server side frameworks
as well. Obviously, since the views are being rendered server side, event and
style bindings will simply be ignored.

Install it via npm:

```
npm install serenade
```

You should now be able to create views with the `.serenade` extension, you can
render them from within express.js like this:

``` javascript
app.get('/:name', function(req, res) {
  res.render('show.serenade', { model: { title: 'Hello' }, layout: false });
});
```

Since Serenade.js has no special syntax for doctypes, an HTML5 doctype is
automatically added. If you do not want this, pass `doctype: false` as an
option to `render`.

# Development

In order to run Serenade.js locally and work on the code base, you will first
need to grab the codebase via git:

    git clone git://github.com/elabs/serenade.js.git
    cd serenade.js

Install dependencies via npm:

    npm install

Run tests with jasmine:

    jasmine-node spec --coffee

Build Serenade.js into a single file:

    cake build

You should now have the built project in `./extras`.

# License

Serenade.js is licensed under the MIT license, see the LICENSE file.

Substantial parts of this codebase where taken from CoffeeScript, licensed
under the MIT license, by Jeremy Ashkenas, see the LICENSE file.

A small part of this codebase was taken from Spine.js, licensed under the MIT
license, by Alex MacCaw, see the LICENSE file.

[service]: https://github.com/elabs/serenade.service.js
