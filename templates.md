---
layout: default
---

# Templates

The Serenade.js template language is inspired by Slim, Jade and HAML, but not
identical to any of these.

Any view in Serenade.js must have a single element as its root node. Elements
may have any number of children. Elements can have attributes within square
brackets.

This is a single element with no children and an id attribute:

``` html
div[id="serenade"]
```

You can use a short form similar to a CSS selector:

``` html
div#serenade.some-class
```

You can omit the element name, which will create div elements:

``` html
#serenade.some-class
```

Indentation is significant and is used to nest elements:

``` html
#page
  article#content
    #child
  footer
```

Attributes may be bound to a model value by prefix the name with `@`:

``` html
div[id=@modelId]
```

Similarly text can be added to any element, this may be either bound or unbound
text or any mix thereof:

``` html
div "Name: " @name
```

## Events

Read about how events are bound from templates under [Controllers](controllers.html).

## Binding styles

We can change the style of an element by binding its `class` attribute to a
model property. If possible, this is what you should do, since it separates
styling from behaviour. Sometimes however, its necessary to bind a style
attribute directly. Consider for example if you have a progress bar, whose
width should be changed based on the `progress` property of a model object.

You can use the special `style:name=value` syntax to dynamically bind styles to
elements like so:

```
div[class="progress" style:width=@progress]
```

Style names should be camelCased, like in JavaScript, not dash-cased, like in
CSS. That means you should write `style:backgroundColor=color`, not
`style:background-color=color`.

## Binding classes

Often you will want to toggle a particular class for an element based on a
bolean value. The Serenade template language has a special syntax for this,
so you don't need to do any additional works in the model layer:

```
div[class:active=@isActive]
```

This will add the class `active` if the `isActive` property on the model is
truthy. If `isActive` is a Serenade property, the class will of course be added
and removed automatically when `isActive` is changed.

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

```
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

On `Serenade.Model` constructors, you can call `collection` to set up a
collection instead of `property`:

``` javascript
var Post = Serenade.Model.extend();
Post.collection("comments");

post = new Post();
post.comments.push({ body: "Hello" });
```

## Views

It can be convenient to split parts of views into subviews. The `view`
instruction does just that:

```
div
  h3 "Most recent comment"
  - view "post"
```

Assuming that there is a post view registered with `Serenade.view('post',
'...')` that view will now be rendered.

It will often be useful to use the `view` and `collection` instructions
together:

```
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

Read about how you can define custom helpers under [Custom helpers](custom_helpers.html).
