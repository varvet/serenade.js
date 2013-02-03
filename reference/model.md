---
layout: default
title: Serenade.Model
reference: true
---

*Serenade.Model is documented in more detail under [models](/models.html).*

Serenade.Model not only provides a few methods to instances derived from it,
but it also provides powerful macros which can be used to define how instances
behave.

The most important is `property`:

``` javascript
var Person = Serenade.Model.extend();

Person.property("name", { serialize: true });
```

This is just a shortcut for:

``` javascript
Serenade.defineProperty(Person.prototype, "name", { serialize: true });
```

Similarly, all other macros are just shortcuts, which define more complicated
properties. Strategically using macros can save you from having to write a lot
of boilerplace code.

## Constructor methods

### find(id)

Find a model with the given id previously added to the identity map.

### extend(function(attributes) {})

Derive a new constructor from Serenade.Model. The constructor function is
optional.

### identityMap: true|false

Set this property to `false` to disable the identity map.

## Macros

### property(names..., options)

Adds one or more properties with the given options. See
[defineProperty](/reference/define_property.html) for a list of options.

### event(name, options)

Adds an event with the given options. See
[defineProperty](/reference/define_event.html) for a list of options.

### delegate(names..., options)

This macro delegates a property to another property. Since Serenade views do
not easily make it possible to chain property access, this is especially
useful. It also automatically sets up dependencies correctly.

This makes it easy to comply with the Law of Demeter. Remember, it's the Law!

It can be used like this:

``` javascript
Person.property("address")
Person.delegate("street", "city", "postalCode", { to: "address" })
```

The `to` option is required.

#### to: String

The property to delegate to

#### prefix: true|String

When true, prefixes the property that delegate creates with the string given to
"to". So in the example above, the properties added would have been
`addressStreet`, `addressCity`, and `addressPostalCode`. When given a string,
that string is used as the prefix instead. For example, when the string `adr`
is given to `prefix`, the resulting properties would have been `adrStreet`,
`adrCity` and `adrPostalCode`.

#### suffix: true|String

Works exactly the same as `prefix`, except it adds a suffix instead.

### collection(name, options)

Adds a property which defaults to an empty collection, and assigning to which
updates the collection, instead of overwriting the property.

### belongsTo(name, options)

Creates an association to another `Serenade.Model` derived constructor.

See [models](/models.html) for an in-depth explanation of associations.

#### as: function() { return Serenade.Model }

When set, assigning an object to the property automatically coerces it to the
correct type. This also enables the `associationId` property.

#### inverseOf: String

The name of the association on the other side, that is the inverse of this one,
this must currently be a `hasMany` association.

### hasMany(name, options)

Creates an association to another `Serenade.Model` derived constructor.

See [models](/models.html) for an in-depth explanation of associations.

#### as: function() { return Serenade.Model }

When set, assigning an object to the property automatically coerces it to the
correct type. This also enables the `associationIds` property.

#### inverseOf: String

The name of the association on the other side, that is the inverse of this one,
this must currently be a `belongsTo` association.

### selection(name, options)

This macro creates a property which filters a collection assigned to another
property. It's probably easiest to illustrate with an example:

``` javascript
Post.collection("comments")
Post.selection("publishedComments", { from: "comments", filter: "published" })
```

#### from: String

The name of the collection to sample from

#### filter: String

The property to filter by, this property should return `true` or `false`.
Passing a function to `filter` will be supported in the future.

## Instance methods

### id

All models have an `id` property by default, you do not need to declare it.

### saved

An event which is triggered when `save` is called.

### changed

An event which is called when any property on the document is changed.

### set(attributes)

Set multiple attributes at the same time.

### save

By default does nothing except triggering a `saved` event.

### toJSON()

Convert the object to JSON, based on the `serialize` attribute given to its
properties. See [models](/models.html) for details.

### toString()

Returns the stringified version of `toJSON()`. This is useful together with
HTML5 localStorage. You can store a Serenade object simply like this:

``` javascript
var Person = Serenade.Model.extend()
Person.property("name", { serialize: true })

var jonas = new Person({ name: "Jonas" })
localStorage.setItem("jonas", jonas)
```
