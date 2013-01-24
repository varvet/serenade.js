---
layout: default
title: Serenade.defineEvent
---

Events can be useful for any number of things. Serenade uses them internally to
keep automatically update the DOM when your model data changes. Serenade
provides `Serenade.defineEvent`, which can be used to declare that an object
has an event:

``` javascript
var object = {}
Serenade.defineEvent(object, "update");

object.update.bind(function() {
  console.log("updated!");
});

object.update.trigger()
```

Unlike other implementations of events, `Serenade.defineEvent` does not add
`bind` and `trigger` methods directly to the object. Instead, defining an event
with a name creates a property with that name on the object, through which the
event can be accessed. This means that `Serenade.defineEvent` can be used on
any object.

## Signature

``` javascript
Serenade.defineEvent(object, name, options)
```

## Options

### `bind: function(fn)`

Takes a function which is called whenever a new listener is attached to this
event. Takes the listener function as an argument.

### `unbind: function(fn)`

Takes a function which is called whenever a listener is detached from this
event. Takes the listener function as an argument.

### `async: true|false`

When this option is `false` and `trigger` is called, all listeners attached to
the event are executed immediately, and `trigger` blocks until this execution
is finished. If the option is `true` then `trigger` returns immediately and is
executed asynchronously.

### `optimize: function(queue) { return args }`

When an event is triggered and the `async` option is `true`, it is pushed onto
a queue, this queue is an array of arrays, where each item in the array contains
the arguments passed to `trigger`.

When the event eventually resolves, the function given to the `optimize` option
is called with the queue as its argument. It is expected to return an array
of arguments which are then passed to all listeners.

Effectively, optimize can reduce a queue of triggered events into a single
invocation of the event. This way, calls to expensive listeners can be reduced
if the event is triggered many times in quick succession.

Consider this highly optimized logging event:

``` javascript
var object = {}
Serenade.defineEvent(object, "log", {
  async: true,
  optimize: function(queue) {
    return [queue.map(function(item) { return item[0] }).join("")];
  }
});
object.log.bind(function(string) { console.log(string) });

object.log.trigger("foo");
object.log.trigger("bar");
```

Eventually, a single log message "foobar" will appear in the log.

## Methods

### `bind(function(args...))`

### `unbind(function(args...))`

### `trigger(args...)`

### `one(function(args...))`

### `resolve()`

### `queue`

### `listeners`
