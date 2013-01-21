---
layout: default
title: Binding data
---

Unfortunately JavaScript does not make it possible to track changes to
arbitrary properties, so in order to update the view automatically as the model
changes, we will have to add some functionality to it.

## Option 1: Serenade.defineProperty

We can use the `Serenade.defineProperty` function to declare our properties,
this will allow Serenade track any changes made to them. It works pretty much
the same way as the standard `Object.defineProperty`, except that it takes a
number of additional options.

``` javascript
var model = { name: "Jonas" };
Serenade.defineProperty(model, "name", { format: function(value) { return value.toUpperCase() }});
Serenade.view('h1 "Hello " @name').render(model); // => <h1>Hello JONAS</h1>
```

## Option 2: Serenade decorator

If we don't need to specify any options, we can use `Serenade` as a decorator
instead:

``` javascript
var model = Serenade({ name: "Jonas" });
Serenade.view('h1 "Hello " @name').render(model)
```

## Option 3: Serenade.Model

While both of these options work well for simple scripts, when you're building
a full application you likely want to define proper models. Serenade provides a
constructor, which gives you a more fully featured starting point.

You can derive your own constructor by calling `extend` on `Serenade.Model`:

``` javascript
var Person = Serenade.Model.extend(function(attributes) {
  // constructor here
});
```

You can declare properties on model constructors and they will be available on
all instances:

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

Read more about models under [Models](models.html).

## Two way data binding

The dynamic properties are one way only; a change in the model triggers a
change in the DOM, but not the other way around. Two way data binding exist so
that a change in the DOM automatically updates the model, and vice versa.

``` javascript
var model = Serenade({ name: "Jonas" });
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

You will often want to show data which is composed of other data. For example,
a person's full name might be a combination of their first and last names. You
can declare such a property like this:

``` javascript
Person.property('fullName', {
  get: function() { return this.firstName + " " + this.lastName },
});
```

Serenade will automatically figure out that `fullName` depends on the values of
`firstName` and `lastName`, and will update `fullName` in your view whenever
those change. You can be explicit about what those dependencies are as well:

``` javascript
Person.property('fullName', {
  get: function() { return this.firstName + " " + this.lastName },
  dependsOn: ['firstName', 'lastName']
});
```

Some properties may depend on properties in other objects. Serenade cannot
figure out these kinds of dependencies automatically, so you will have to
specify them explicitly. For this, you can use the syntax `object.property`,
like this:

``` javascript
Book.property("author");
Book.property("authorName", {
  get: function() { return this.author.name; },
  dependsOn: "author.name"
});
```

It is also possible to reach into collections, and depend on the values of
properties of each item in the collections by using a colon as the separator,
as in `object:property`. For example:

``` javascript
Book.collection("authors");
Book.property("authorNames", {
  get: function() { return this.authors.map(function(a) { return a.name }); },
  dependsOn: "authors:name"
});
```

