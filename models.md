---
layout: default
title: Serenade.Model
---

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
person2.name; # => 'John'
person2.age; # => 23
```

Here `person2` and `person1` are both variables which point to the same object,
and that object's properties are a combination of the properties assigned to
both calls of the constructor function.

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
be added, so that you can do `person.first_name = 'Jonas'`. This is especially
useful when providing JSON data from the server, as it will allow you to use
the correct naming conventions both on the server and client.

You can retrieve the serialized represenation like this:

``` javascript
person.toJSON()
```

If you send in the model to `JSON.stringify`, that will happen automatically so
you can simply do `JSON.stringify(person)`.

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

If you assign a function to a property, that function will automatically be
used as the getter function. This is especially useful for cleaning up classes
in CoffeeScript, if you have a lot of property declarations:

``` coffeescript
class Person extends Serenade.Model
  @property "firstName", "lastName", "name"

  name: ->
    @firstName + " " + @lastName

new Person(firstName: "Jonas", lastName: "Nicklas").name # => "Jonas Nicklas"
```
