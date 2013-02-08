---
layout: default
title: Serenade.defineProperty
reference: true
---

The `Serenade.defineProperty` function is the cornerstone of Serenade.js. Declaring
properties through this function enables Serenade to listen to changes to these
properties from the view.

If you're using `Serenade.Model`, you likely won't use this function directly,
but instead use the `property` macro, which is just a shortcut to this
function, and takes the same options.

The API and behaviour of this function is quite similar to `Object.defineProperty`,
which is part of the ECMAScript 5 standard and implemented by all modern browsers.
You can read more about it [at MDN](https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Object/defineProperty).

## Signature

``` javascript
Serenade.defineProperty(object, name, options)
```

## Arguments

### object

The object on which to define the property.

### name

The name of the property to be defined.

## Options

### enumerable: true|false

Unlike Object.defineProperty, Properties added via Serenade.defineProperty
are enumerable by default. Set this to `false` to make the property not
enumerable.

### value: Object

Setting this vill set the property to the given value after it is added,
respecting any declared setters. Unlike `Object.defineProperty`, the property
is always writable.

### get: function() { return Object }

Declares a getter to be used for this property. The getter is executed in the
context of the object. The value returned by the getter is not cached, if
caching is required, manual memoization can be used.

### set: function(Object)

Declares a setter to be used for this property. The setter is executed in the
context of the object. When overriding the setter, the getter will most
likely need to be changed as well. The name of the property Serenade uses
internally to store the value is not a public API and subject to change. Use
`Object.defineProperty` to declare a non-enumerable property to cache the
value.

### format: function(Object) { return Object }

When a formatter function is declared, it will be used by Serenade when
inside a view. This allows you to for example add formatting for numbers or
dates. The formatter function is passed the value returned by the getter
function and executed in the context of the object.

### serialize: true|String|function() { return [key, value] }

When given a string, this will set up an alias for the property with the
given name. For example if `fooBar` is serialized as `foo_bar`, then
assigning to `foo_bar` will automatically update `fooBar`. Other values
are only used by `Serenade.Model`.

### dependsOn: String|Array[String]

Specify a list of dependencies that affect the value of this property. You
will likely only want to change this if you've used the `get` property as
well. The value given can be either a single string or an array of strings.
Note that Serenade can discover dependencies within the same object automatically.

### async: true|false

When set to true, listeners listening for changes to this property are
triggered asynchronously. This has the advantage that Serenade can optimize
multiple updates to the same property into triggering only a single change
event.

If this option is not given, the value is taken from `Serenade.async`.

### changed: true|false|function(old, new) { return Boolean }

This property controls when change events are triggered for a given property.
If the option is set to `false` change events are never triggered for this
property. The default is `true` which always triggers a change event.

If a function is given, the function receives the value of the property the
last time a change event was triggered, as well as the current value. If the
function returns a truthy value, the change event will be triggered.

### cache: true|false

When `true` and the `get` option is given, the value of the property is cached.
This is useful if the computation done by `get` is expensive. The cache is
expired whenever a change event for this property is triggered.

## The property accessor

When a property is declared with `Serenade.defineProperty`, it can be reflected
upon by suffixing the name of the property with `_property`. For example, imagine
if we have the following:

``` javascript
object = {}
Serenade.defineProperty(object, "name")
```

We can now access metadata about the `name` property like this:

``` javascript
object.name_property.get()
object.name_property.format()
object.name_property.bind(function() {
  console.log("name changed!");
});
```

## Methods

### get()

Returns the value of the property.

### set(value)

Set the property to the given value.

### format()

If the `format` option was given to the property, the value is formatted with
it, otherwise it is returned verbatim.

### trigger(args...)

Trigger a change event on this property and all properties that depend on it.

### bind(function(args...))

Bind a function to trigger whenever the property is changed.

### one(function(args...))

Bind a function to trigger the next time the property is changed.

### unbind(function(args...))

Remove a previously bound function

### listeners

Return a list of functions currently listening for changes to this property.

### dependents

Return a list of properties within the same object which depend on this
property.
