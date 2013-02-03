---
layout: default
title: Serenade.Collection
reference: true
---

Serenade collections emulate JavaScript arrays as closely as possible. The key
difference is that it is possible to track changes to a Serenade collection,
whereas this is not possible with regular arrays. Collections can be
instantiated like this:

``` javascript
var empty = new Serenade.Collection()
var names = new Serenade.Collection(["Jonas", "Kim"])
```

Serenade collections are fully compatible with CoffeeScript's array
comprehensions:

``` coffeescript
names = new Serenade.Collection(["Jonas", "Kim"])
for name in names
  console.log name
```

Unfortunately, it is not currently possible to track changes to arbitrary
properties in JavaScript. Therefore, if you directly assign a value to an array
index, Serenade cannot track that change and it won't show up in your views. In
other words:

``` javascript
var names = new Serenade.Collection(["Jonas", "Kim"])
names[0] = "CJ" // Never do this!
names.set(0, "CJ") // Always do this!
```

Aside from that very important difference, collection should behave almost
identical to regular arrays. Serenade collections have all Array prototype
methods defined in ES5. [MDN documents these in detail][mdn].

All of these methods which would ordinarily return a new array, such as `map`,
`filter` and `slice`, will return a new Serenade collection instead.

In *addition* to the standard array methods, Serenade collections add some
other useful methods:

## Methods

### get(index)

Return the value at the given array index, it's safe to use `collection[index]`
instead, this is mostly for symetry with `set`.

### set(index, Object)

Set the given index to the given value. Always use this over `collection[index]
= value`

### update(Array|Collection)

Empty this collection and replace all its element with the given array or
collection.  This is a mutative way to replace a collection's entire contents.

### sortBy(String)

Sort the collection by the given attribute

### includes(Object)

Returns true if the collection contains the given object, otherwise returns
false.

### find(function(item) { return true|false })

Returns the first item for which the given function returns true.

### insertAt(index, Object)

Inserts the given object at the given index. A shortcut for `splice(index, 0,
Object)`.

### deleteAt(index)

Remove the object at the given index from the collection. A shortcut for
`splice(index, 1)`.

### delete(item)

Delete the given item from the collection.

### first

Returns the first item in the collection (note that this is a property, not a
function).

### last

Returns the last item in the collection (note that this is a property, not a
function).

### toArray()

Returns a true array from this collection.

### clone()

Returns a shallow copy of this collection. Does not copy listeners to the new
collection.

[mdn]: https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Array#Methods_of_Array_instances
