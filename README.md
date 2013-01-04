# Serenade.js

[![Build Status](https://secure.travis-ci.org/elabs/serenade.js.png)](http://travis-ci.org/elabs/serenade.js)

Serenade.js is yet another MVC client side JavaScript framework. Why do we
indulge in recreating the wheel? We believe that Serenade.js more closely follows
the ideas of classical MVC than competing frameworks and has a number of other
advantages as well:

* Clean, simple and logic less template language
* Data bindings keep your views up-to-date without any extra work
* Powerful caching features
* Absolutely no dependencies, everything works without jQuery
* No need to inherit from base classes anywhere (though you can if you want)

**Need help?** Ask your question on our
[mailing list](http://groups.google.com/group/serenadejs).

## Important Note!

This is an ongoing, alpha level project. Be prepared that the API might change
and bugs might occur.

## Browser support

Serenade.js should work in all modern browsers, including IE9. IE8 and
below are not supported.

## Download

Download here: https://github.com/elabs/serenade.js/downloads

You can integrate Serenade into Ruby on Rails through the
[serenade.rb](https://github.com/elabs/serenade.rb) gem.

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
var controller = { say: function(model) { alert("Hello " + model.name) } };
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
arbitrary properties, so in order to update the view automatically as the model
changes, we will have to add some functionality to it.

We can use the `Serenade.defineProperty` function to declare our properties,
this will allow Serenade track any changes made to them. It works pretty much
the same way as the standard `Object.defineProperty`, except that it takes a
number of additional options.

``` javascript
var model = { name: "Jonas" };
Serenade.defineProperty(model, "name", { format: function(value) { return value.toUpperCase() }});
Serenade.view('h1 "Hello " @name').render(model); // => <h1>Hello JONAS</h1>
```

If we don't need to specify any options, we can use `Serenade` as a decorator
instead:

``` javascript
var model = Serenade({ name: "Jonas" });
Serenade.view('h1 "Hello " @name').render(model)
```

While both of these options work well for simple scripts, when you're building
a full application you likely want to define proper models.  Serenade provides
a constructor, which provides a more fully featured starting point. It is
documented in more detail later in this README.

You can derive your own constructor by calling `extend` on `Serenade.Model`:

``` javascript
var Person = Serenade.Model.extend(function(attributes) {
  // constructor here
});
```

You can declare properties on model constructors and they will be available
on all instances:

``` javascript
Person.property("name", { format: function(value) { return value.toUpperCase() }});
model = new Person()
model.name = "Jonas"
Serenade.view('h1 "Hello " @name').render(model); // => <h1>Hello JONAS</h1>
```

If you're using CoffeeScript, you can use the standard CoffeeScript inheritance
mechanism:

``` coffeescript
class Person extends Serenade.Model
  @property "name", format: (value) -> value.toUpperCase()
```

If you assign a function to a property, that function will automatically be
used as the getter function. This is especially useful for cleaning up classes
in CoffeeScript, if you have a lot of property declarations:

``` coffeescript
class Person extends Serenade.Model
  @properties "firstName", "lastName", "name"

  name: ->
    @firstName + " " + @lastName

new Person(firstName: "Jonas", lastName: "Nicklas").name # => "Jonas Nicklas"
```

## Two way data binding

The dynamic properties are one way only; a change in the model triggers a
change in the DOM, but not the other way around. Two way data binding exist so
that a change in the DOM automatically updates the model, and vice versa.

``` javascript
var model = { name: "Jonas" };
var element = Serenade.view('input[type="text" binding=@name]').render(model, {});
```

When the form is submitted, the model is updated with the values from the form
element. It is also possible to update the model when an event occurs on the
form elements, such as a `change` or `keyup` event:

``` javascript
var model = { name: "Jonas" };
var element = Serenade.view('input[type="text" binding:keyup=@name]').render(model, {});
```

Currently Serenade supports binding to text fields, text areas, checkboxes,
radio buttons and select boxes (not multiple selects). Support for other form
elements is planned.

## Format

Sometimes you want the value of the property to appear differently in a view
than when handling the property internally. Consider a property representing a
monetary value. You would want to handle this as an integer in the model, but
the view should show it properly formatted, with currency information and so
on. You can use the `format` option for this.

``` javascript
Person.property('price', { format: function(value) { return "€ " + value } });
```

To retrieve a formatted value, call `Serenade.format(model, 'price')`.

Format functions also works for collections. The entire collection object will
be passed as an argument.

``` javascript
Person.collection('sizes', { format: function(collection) { return collection.list.join(", ") } });
```

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
Person.property('fullName', {
  get: function() { return this.firstName + " " + this.lastName },
  dependsOn: ['firstName', 'lastName']
});
```

A property can specify that it depends upon the value of a property in another
object, by "reaching" into that object, with the `object.property` syntax. For
example:

``` javascript
Book.property("author");
Book.property("authorName", {
  get: function() { return this.author.name; },
  dependsOn: "author.name")
});
```

It is also possible to reach into collections, and depend on the values of
properties of each item in the collections by using a colon as the separator,
as in `object:property`. For example:

``` javascript
Book.collection("authors");
Book.property("authorNames", {
  get: function() { return this.author.map(function(a) { return a.name }); },
  dependsOn: "authors:name")
});
```

## Template Language

The Serenade.js template language is inspired by Slim, Jade and HAML, but not
identical to any of these.

Any view in Serenade.js must have a single element as its root node. Elements
may have any number of children. Elements can have attributes within square
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

## Controllers

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
implement a method called `loaded` then it is called with the model and root
element of the view after the view has rendered:

``` javascript
var PostController = function(post) {};

PostController.prototype.loaded = function(model, view) {
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
  loaded: (post, view) -> new Datepicker(view.querySelector("#date"))
  favourite: -> @post.favourite = true

Serenade.render("post", post, PostController)
```

## Events

Events are bound and given a name in the view. When the event is triggered,
Serenade looks up the property with the name of the event on the controller and
calls it as a function. Such a function is called an `action`.

Actions receive as parameters the model, the element that the event was bound
to, and the event object itself.

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
  like: function(model) { model.set('liked', true) }
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
  like: function(model, element, event) {
    model.set('liked', true)
    event.preventDefault()
  }
};
```

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

We can change the style of an element by binding its `class` attribute to a
model property. If possible, this is what you should do, since it separates
styling from behaviour. Sometimes however, its necessary to bind a style
attribute directly. Consider for example if you have a progress bar, whose
width should be changed based on the `progress` property of a model object.

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

If `comments` is an instance of `Serenade.Collection`, Serenade.js will
dynamically update this collection as comments are added, removed or changed:

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
use a specific controller for this new view. You can register a controller to
be used for a particular view like this:

``` javascript
var CommentController = function() {};
Serenade.controller('comment', CommentController);
```

Serenade.js will now infer that you want to use a `CommentController` with the
`comment` view.

## Custom helpers

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

You can use any library you want to generate the DOM element, but it must be an
actual element, returning a string is not possible, neither is returning
multiple elements or undefined.

Beware if you're using jQuery that you need to use the `get` function to
extract the actual DOM element, for example:

``` javascript
Serenade.Helpers.link = function(name, url) {
  var a = $('<a></a>').attr('href', url).text(name);
  return a.get(0);
};
```

Inside the helper, you have access to a couple of things through `this`. You can
use `this.model` or `this.controller` to access the current model and controller.

For example if you had a model like this:

``` javascript
var model = {
  web: 'http://www.google.com',
  images: 'http://images.google.com/'
};
```

You might want to create a function to link to these easily like so:

``` javascript
Serenade.Helpers.link = function(link) {
  var a = document.createElement('a');
  a.setAttribute('href', this.model[link]);
  a.appendChild(document.createTextNode(link));
  return a;
};
```

And then use it in your view:

```
div
  - link @web
  - link @images
```

Both the `@web` and `"Google"` syntaxes produce strings as argument. It is
convention to use the syntax with an `@` when the argument is meant to
reference a model attribute.

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

The `render` takes the model as its second and the controller as its third
argument. You can call `render` multiple times, possibly sending in different
models and/or controllers for each invocation. Render returns a document
fragment, so like in the example above, it is no problem for a helper have
multiple direct children.

# Serenade.Model

Serenade.Model provides a more fully featured starting point for creating
feature rich model objects. You can of course bind to instances of
`Serenade.Model` in views and changes are reflected there dynamically.

For simplicity's sake we will refer to instances of constructors derived from
`Serenade.Model` as documents.

## Identity map

Serenade.Model assumes you have a property named `id` and that this uniquely
identifies each document. Provided that such a property exists, documents are
fetched from an in-memory cache, so that multiple queries for the same document
id return the same object. This is key to working effectively with objects
bound to views.

``` javascript
var Person = Serenade.Model.extend();

person1 = new Person({ id: 1, name: 'John'} );
person2 = new Person({ id: 1, age: 23 });
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

You can retrieve the serialized represenation like this:

``` javascript
person.toJSON()
```

If you send in the model to `JSON.stringify`, that will happen automatically so
you can simply do `JSON.stringify(person)`.

## Associations

You can declare that a model has an associated model. For example, each comment
might belong to a post, you can declare this like this:

``` javascript
Comment.belongsTo('post', { as: function() { return Post } });
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
Post.hasMany('comments', { as: function() { return Comment } });
```

If the `constructor` property is omitted from either declaration, then the
associated documents will be plain objects instead.

You can declare that an association has a property on the other side, this
will automatically set the inverse association.

``` javascript
Post.hasMany('comments', { inverseOf: "post", as: function() { return Comment } });
Comment.belongsTo('post', { inverseOf: "comments", as: function() { return Post } });
```

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

# Express.js support

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

Run the tests:

    npm test

Build Serenade.js into a single file:

    npm run-script build

You should now have the built project in `./extras`.

Run the example app:

    npm run-script examples

# License

Serenade.js is licensed under the MIT license, see the LICENSE file.

Substantial parts of this codebase where taken from CoffeeScript, licensed
under the MIT license, by Jeremy Ashkenas, see the LICENSE file.

[service]: https://github.com/elabs/serenade.service.js
