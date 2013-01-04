require './../spec_helper'
{Serenade} = require '../../src/serenade'
{Collection} = require '../../src/collection'
{expect} = require('chai')

describe 'Serenade.Model.hasMany', ->
  it 'allows objects to be added and retrieved', ->
    class Comment extends Serenade.Model
      @property 'body'
    class Post extends Serenade.Model
      @hasMany 'comments', as: -> Comment
    comment1 = new Comment(body: 'Hello')
    comment2 = new Comment(body: 'Monkey')
    post = new Post(comments: [comment1, comment2])
    expect(post.comments[0]).to.eql(comment1)
    expect(post.comments[1]).to.eql(comment2)
  it 'uses the given constructor', ->
    class Comment extends Serenade.Model
      @property 'body'
    class Post extends Serenade.Model
      @hasMany 'comments', as: -> Comment
    post = new Post(comments: [{ body: 'Hello' }, { body: 'Monkey' }])
    expect(post.comments[0].constructor).to.eql(Comment)
    expect(post.comments[1].constructor).to.eql(Comment)
    expect(post.comments[0].body).to.eql('Hello')
    expect(post.comments[1].body).to.eql('Monkey')
  it 'creates plain objects if there is no constructor given', ->
    class Comment extends Serenade.Model
      @property 'body'
    class Post extends Serenade.Model
      @hasMany 'comments'
    post = new Post(comments: [{ body: 'Hello' }, { body: 'Monkey' }])
    expect(post.comments[0].constructor).to.eql(Object)
    expect(post.comments[1].constructor).to.eql(Object)
    expect(post.comments[0].body).to.eql('Hello')
    expect(post.comments[1].body).to.eql('Monkey')
  it 'updates the ids property as it changes', ->
    class Comment extends Serenade.Model
      @property 'body'
    class Post extends Serenade.Model
      @hasMany 'comments', as: -> Comment
    post = new Post(comments: [{ id: 4 }, { id: 3 }])
    expect(post.commentsIds[0]).to.eql(4)
    expect(post.commentsIds[1]).to.eql(3)
    post.comments = [{id: 12}]
    expect(post.commentsIds[0]).to.eql(12)
    expect(post.commentsIds[1]).to.not.exist
  it 'is updated if the ids property changes', ->
    class Comment extends Serenade.Model
      @property 'body'
    class Post extends Serenade.Model
      @hasMany 'comments', as: -> Comment
    comment = new Comment(id: 5, body: 'Hello')
    comment = new Comment(id: 8, body: 'World')
    comment = new Comment(id: 9, body: 'Cat')
    post = new Post(commentsIds: [5,8], body: 'Hello')
    expect(post.comments[0].body).to.eql('Hello')
    expect(post.comments[1].body).to.eql('World')
    post.commentsIds = [8,9]
    expect(post.comments[0].body).to.eql('World')
    expect(post.comments[1].body).to.eql('Cat')
  it 'serializes the entire associated documents', ->
    class Comment extends Serenade.Model
      @property 'body', serialize: true
    class Post extends Serenade.Model
      @hasMany 'comments', serialize: true, as: -> Comment
    post = new Post(comments: [{ body: 'Hello' }, { body: 'Monkey' }])
    serialized = post.toJSON()
    expect(serialized.comments[0].body).to.eql('Hello')
    expect(serialized.comments[1].body).to.eql('Monkey')
  it 'serializes the ids', ->
    class Comment extends Serenade.Model
      @property 'body', serialize: true
    class Post extends Serenade.Model
      @hasMany 'comments', serializeIds: true, as: -> Comment
    post = new Post(comments: [{ id: 5, body: 'Hello' }, { id: 8, body: 'Monkey' }])
    serialized = post.toJSON()
    expect(serialized.commentsIds[0]).to.eql(5)
    expect(serialized.commentsIds[1]).to.eql(8)
  it 'can observe changes to items in the collection', ->
    class Comment extends Serenade.Model
      @property 'confirmed'
    class Post extends Serenade.Model
      @hasMany 'comments', as: -> Comment
      @property 'confirmedComments', dependsOn: 'comments:confirmed'
    post = new Post(name: "test")
    post.confirmedComments
    post.comments = [{ id: 5, body: 'Hello', confirmed: true }, { id: 8, body: 'Monkey', confirmed: false }]
    comment = post.comments[1]
    expect(-> comment.confirmed = true).to.triggerEvent(post.change_confirmedComments)
  it 'can set itself on its inverse relation', ->
    class Comment extends Serenade.Model
      @belongsTo "post"
    class Post extends Serenade.Model
      @hasMany 'comments', inverseOf: "post", as: -> Comment
    post = new Post(comments: [{ body: "hey" }])
    expect(post.comments[0].post).to.eql(post)
  it 'can handle circular inverse associations', ->
    class Comment extends Serenade.Model
      @belongsTo "post", inverseOf: "comments", as: -> Post
    class Post extends Serenade.Model
      @hasMany 'comments', inverseOf: "post", as: -> Comment
    post = new Post(comments: [{ body: "hey" }])
    expect(post.comments[0].post).to.eql(post)
    expect(post.comments.length).to.eql(1)
  it 'does not push itself twice to its inverse association', ->
    class Comment extends Serenade.Model
      @belongsTo "post", inverseOf: "comments", as: -> Post
    class Post extends Serenade.Model
      @hasMany 'comments', inverseOf: "post", as: -> Comment
    post = new Post()
    post.comments.push({})
    expect(post.comments[0].post).to.eql(post)
    expect(post.comments.length).to.eql(1)

describe ".delegate", ->
  it "sets up delegated attributes", ->
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author"
    post = new Post(author: { name: "Jonas", email: "jonas@elabs.se" })
    expect(post.name).to.eql("Jonas")
    expect(post.email).to.eql("jonas@elabs.se")
  it "returns undefined when the attribute being delegated to is undefined", ->
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author"
    post = new Post(author: undefined)
    expect(post.name).to.eql(undefined)
    expect(post.email).to.eql(undefined)
  it "notifies of changes when delegated attributes are changed", ->
    author = new Serenade.Model(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author"
    post = new Post(author: author)
    post.name
    post.email
    expect(-> author.name = "peter").to.triggerEvent(post.change_name, with: ["peter"])
    expect(-> author.email = "peter@elabs.se").to.triggerEvent(post.change_email, with: ["peter@elabs.se"])
  it "can set prefix", ->
    author = new Serenade.Model(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author", prefix: true
    post = new Post(author: { name: "Jonas", email: "jonas@elabs.se" })
    expect(post.authorName).to.eql("Jonas")
    expect(post.authorEmail).to.eql("jonas@elabs.se")
  it "can set suffix", ->
    author = new Serenade.Model(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author", suffix: true
    post = new Post(author: { name: "Jonas", email: "jonas@elabs.se" })
    expect(post.nameAuthor).to.eql("Jonas")
    expect(post.emailAuthor).to.eql("jonas@elabs.se")

describe "#id", ->
  it "updates identify map when changed", ->
    class Person extends Serenade.Model
      @property "name"
    person = new Person(id: 5, name: "Nicklas")
    person.id = 10
    expect(person.id).to.eql(10)
    expect(Person.find(5).name).to.eql(undefined)
    expect(Person.find(10).name).to.eql("Nicklas")

describe '.toJSON', ->
  beforeEach ->
    class @Person extends Serenade.Model
  it 'serializes any properties marked as serializable', ->
    @Person.property('foo', serialize: true)
    @Person.property('barBaz', serialize: true)
    @Person.property('quox')
    @object = new @Person(foo: 23, barBaz: 'quack', quox: 'schmoo', other: 55)
    serialized = @object.toJSON()
    expect(serialized.foo).to.eql(23)
    expect(serialized.barBaz).to.eql('quack')
    expect(serialized.quox).to.not.exist
    expect(serialized.other).to.not.exist
  it 'serializes properties with the given string as key', ->
    @Person.property('foo', serialize: true)
    @Person.property('barBaz', serialize: 'bar_baz')
    @Person.property('quox')
    @object = new @Person(foo: 23, barBaz: 'quack', quox: 'schmoo', other: 55)
    serialized = @object.toJSON()
    expect(serialized.foo).to.eql(23)
    expect(serialized.bar_baz).to.eql('quack')
    expect(serialized.barBaz).to.not.exist
    expect(serialized.quox).to.not.exist
    expect(serialized.other).to.not.exist
  it 'serializes a property with the given function', ->
    @Person.property('foo', serialize: true)
    @Person.property('barBaz', serialize: -> ['bork', @foo.toUpperCase()])
    @Person.property('quox')
    @object = new @Person(foo: 'fooy')
    serialized = @object.toJSON()
    expect(serialized.foo).to.eql('fooy')
    expect(serialized.bork).to.eql('FOOY')
    expect(serialized.barBaz).to.not.exist
  it 'serializes an object which has a serialize function', ->
    @Person.property('foo', serialize: true)
    @object = new @Person(foo: { toJSON: -> 'from serialize' })
    serialized = @object.toJSON()
    expect(serialized.foo).to.eql('from serialize')
  it 'serializes an array of objects which have a serialize function', ->
    @Person.property('foo', serialize: true)
    @object = new @Person(foo: [{ toJSON: -> 'from serialize' }, {toJSON: -> 'another'}, "normal"])
    serialized = @object.toJSON()
    expect(serialized.foo[0]).to.eql('from serialize')
    expect(serialized.foo[1]).to.eql('another')
    expect(serialized.foo[2]).to.eql('normal')
  it 'serializes a Serenade.Collection by virtue of it having a serialize method', ->
    @Person.property('foo', serialize: true)
    collection = new Collection([{ toJSON: -> 'from serialize' }, {toJSON: -> 'another'}, "normal"])
    @object = new @Person(foo: collection)
    serialized = @object.toJSON()
    expect(serialized.foo[0]).to.eql('from serialize')
    expect(serialized.foo[1]).to.eql('another')
    expect(serialized.foo[2]).to.eql('normal')
