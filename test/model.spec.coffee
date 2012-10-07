require './spec_helper'
{Serenade} = require '../src/serenade'
{Cache} = require '../src/cache'
{expect} = require('chai')

describe 'Serenade.Model', ->
  describe '#constructor', ->
    it 'sets the given properties', ->
      john = new Serenade.Model(name: 'John', age: 23)
      expect(john.get('age')).to.eql(23)
      expect(john.get('name')).to.eql('John')

    it 'returns the same object if given the same id', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Serenade.Model(id: 'j123', age: 46)

      expect(john2.test).to.be.ok
      expect(john2.get('age')).to.eql(46)
      expect(john2.get('name')).to.eql('John')

    it 'returns different instances for same id on different constructors', ->
      Test1 = class Test extends Serenade.Model
      Test2 = class Test extends Serenade.Model

      john1 = new Test1(id: 'j123', name: 'John', age: 23)
      john2 = new Test2(id: 'j123', age: 46)

      expect(john1).not.to.eql(john2)
      expect(john1.get('age')).to.eql(23)
      expect(john1.get('name')).to.eql("John")
      expect(john2.get('age')).to.eql(46)
      expect(john2.get('name')).to.eql(undefined)

    it 'returns a new object when given a different id', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Serenade.Model(id: 'j456', age: 46)

      expect(john2.test).not.to.be.ok
      expect(john2.get('age')).to.eql(46)
      expect(john2.get('name')).to.not.exist

    it 'does not store in local storage if local storage is false', ->
      class Test extends Serenade.Model
        @property 'test', serialize: 'testing'

      test = new Test(id: 5, test: 'foo')
      expect(Cache.retrieve(Test, 5)).to.not.exist

    it 'persists to cache on any changes if localStorage is true', ->
      class Test extends Serenade.Model
        @property 'test', serialize: 'testing'
        @localStorage = true

      test = new Test(id: 5, test: 'foo')
      expect(Cache.retrieve(Test, 5).test).to.eql('foo')
      test.set('test', 'monkey')
      expect(Cache.retrieve(Test, 5).test).to.eql('monkey')

    it 'persists to cache when saved if localStorage is "save"', ->
      class Test extends Serenade.Model
        @property 'test', serialize: 'testing'
        @localStorage = 'save'

      test = new Test(id: 5, test: 'foo')
      expect(Cache.retrieve(Test, 5)).to.not.exist
      test.set('test', 'monkey')
      expect(Cache.retrieve(Test, 5)).to.not.exist
      test.save()
      expect(Cache.retrieve(Test, 5).test).to.eql('monkey')

    it 'persists to cache when saved if localStorage is true', ->
      class Test extends Serenade.Model
        @collection "names", serialize: true
        @localStorage = true

      test = new Test(id: 5, names: [{ first: "Jonas" }])
      test.names[0].first = "Peter"
      expect(Cache.retrieve(Test, 5).names[0].first).to.eql("Jonas")
      test.save()
      expect(Cache.retrieve(Test, 5).names[0].first).to.eql("Peter")

  describe '.extend', ->
    it 'sets up prototypes correctly', ->
      Test = Serenade.Model.extend()
      test = new Test(foo: 'bar')
      expect(test.get('foo')).to.eql('bar')
    it 'copies over class variables', ->
      Test = Serenade.Model.extend()
      expect(typeof Test.hasMany).to.eql('function')
    it 'runs the provided constructor function', ->
      Test = Serenade.Model.extend(-> @foo = true)
      test = new Test()
      expect(test.foo).to.be.ok
    it 'works with the identity map', ->
      Person = Serenade.Model.extend()
      john1 = new Person(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Person(id: 'j123', age: 46)

      expect(john2.test).to.be.ok
      expect(john2.get('age')).to.eql(46)
      expect(john2.get('name')).to.eql('John')

  describe '.uniqueId', ->
    it 'is different for different classes', ->
      Test1 = class Test extends Serenade.Model
      Test2 = class Test extends Serenade.Model
      expect(Test1.uniqueId()).not.to.eql(Test2.uniqueId())
    it 'returns the same results when called multiple times', ->
      Test = class Test extends Serenade.Model
      expect(Test.uniqueId()).to.eql(Test.uniqueId())
    it 'is different for subclasses', ->
      Test1 = class Test extends Serenade.Model
      Test1.uniqueId()
      Test2 = class Test extends Test1
      expect(Test1.uniqueId()).not.to.eql(Test2.uniqueId())

  describe '.find', ->
    it 'creates a new blank object with the given id', ->
      document = Serenade.Model.find('j123')
      expect(document.get('id')).to.eql('j123')
    it 'returns the same object if it has previously been initialized', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John')
      john1.test = true
      john2 = Serenade.Model.find('j123')
      expect(john2.test).to.be.ok
      expect(john2.get('name')).to.eql('John')

  describe '.belongsTo', ->
    it 'allows model to be assigned and retrieved', ->
      class Post extends Serenade.Model
        @property 'body'
      class Comment extends Serenade.Model
        @belongsTo('post', as: -> Post)
      post = new Post(body: 'Hello')
      comment = new Comment(post: post)
      expect(comment.post).to.eql(post)
    it 'uses the given constructor when assigning to attributes', ->
      class Post extends Serenade.Model
        @property 'body'
      class Comment extends Serenade.Model
        @belongsTo('post', as: -> Post)
      comment = new Comment(post: { body: 'Hello' })
      expect(comment.post.constructor).to.eql(Post)
      expect(comment.post.body).to.eql('Hello')
    it 'creates a plain object if there is no constructor given', ->
      class Comment extends Serenade.Model
        @belongsTo('post')
      comment = new Comment(post: { body: 'Hello' })
      expect(comment.post.constructor).to.eql(Object)
      expect(comment.post.body).to.eql('Hello')
    it 'updates the id property as it changes', ->
      class Comment extends Serenade.Model
        @belongsTo('post')
      comment = new Comment(post: { id: 5, body: 'Hello' })
      expect(comment.postId).to.eql(5)
      comment.post = id: 12
      expect(comment.postId).to.eql(12)
    it 'is updated if the id property changes', ->
      class Post extends Serenade.Model
        @property 'body'
      class Comment extends Serenade.Model
        @belongsTo('post', as: -> Post)
      post1 = new Post(id: 5, body: 'Hello')
      post2 = new Post(id: 12, body: 'World')
      comment = new Comment(postId: 5)
      expect(comment.post.body).to.eql('Hello')
      comment.postId = 12
      expect(comment.post.body).to.eql('World')
    it 'does nothing when given an undefined id', ->
      class Post extends Serenade.Model
      class Comment extends Serenade.Model
        @belongsTo('post', as: -> Post)
      comment = new Comment(postId: undefined)
      expect(comment.post).to.eql(undefined)
    it 'can handle ids given as strings', ->
      class Post extends Serenade.Model
        @property 'body'
      class Comment extends Serenade.Model
        @belongsTo('post', as: -> Post)
      post1 = new Post(id: 5, body: 'Hello')
      comment = new Comment(postId: "5")
      expect(comment.post.body).to.eql('Hello')
    it 'serializes the entire associated document', ->
      class Post extends Serenade.Model
        @property 'body', serialize: true
      class Comment extends Serenade.Model
        @belongsTo('post', serialize: true, as: -> Post)
      comment = new Comment(post: { body: "foo" })
      expect(comment.toJSON().post.body).to.eql("foo")
    it 'serializes the id', ->
      class Post extends Serenade.Model
        @property 'body', serialize: true
      class Comment extends Serenade.Model
        @belongsTo('post', serializeId: true, as: -> Post)
      comment = new Comment(post: { id: 5, body: "foo" })
      expect(comment.toJSON().postId).to.eql(5)
    it 'can add itself to its inverse relation', ->
      class Comment extends Serenade.Model
        @belongsTo "post", inverseOf: "comments", as: -> Post
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
      comment = new Comment(post: { body: "hey" })
      expect(comment.post.comments[0]).to.eql(comment)
    it 'does not add itself multiple times to the same inverse relation', ->
      class Comment extends Serenade.Model
        @belongsTo "post", inverseOf: "comments", as: -> Post
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
      post = new Post()
      comment = new Comment(post: post)
      comment.post = post
      expect(post.comments[0]).to.eql(comment)
      expect(post.comments.length).to.eql(1)
    it 'removes itself from its previous inverse relation', ->
      class Comment extends Serenade.Model
        @belongsTo "post", inverseOf: "comments", as: -> Post
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
      post = new Post()
      otherPost = new Post()
      comment = new Comment(post: post)
      comment.post = otherPost
      expect(post.comments.length).to.eql(0)
      expect(otherPost.comments[0]).to.eql(comment)
      expect(otherPost.comments.length).to.eql(1)

  describe '.hasMany', ->
    it 'allows objects to be added and retrieved', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
      comment1 = new Comment(body: 'Hello')
      comment2 = new Comment(body: 'Monkey')
      post = new Post(comments: [comment1, comment2])
      expect(post.comments.get(0)).to.eql(comment1)
      expect(post.comments.get(1)).to.eql(comment2)
    it 'uses the given constructor', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
      post = new Post(comments: [{ body: 'Hello' }, { body: 'Monkey' }])
      expect(post.comments.get(0).constructor).to.eql(Comment)
      expect(post.comments.get(1).constructor).to.eql(Comment)
      expect(post.comments.get(0).body).to.eql('Hello')
      expect(post.comments.get(1).body).to.eql('Monkey')
    it 'creates plain objects if there is no constructor given', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @hasMany 'comments'
      post = new Post(comments: [{ body: 'Hello' }, { body: 'Monkey' }])
      expect(post.comments.get(0).constructor).to.eql(Object)
      expect(post.comments.get(1).constructor).to.eql(Object)
      expect(post.comments.get(0).body).to.eql('Hello')
      expect(post.comments.get(1).body).to.eql('Monkey')
    it 'updates the ids property as it changes', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
      post = new Post(comments: [{ id: 4 }, { id: 3 }])
      expect(post.commentsIds.get(0)).to.eql(4)
      expect(post.commentsIds.get(1)).to.eql(3)
      post.comments = [{id: 12}]
      expect(post.commentsIds.get(0)).to.eql(12)
      expect(post.commentsIds.get(1)).to.not.exist
    it 'is updated if the ids property changes', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
      comment = new Comment(id: 5, body: 'Hello')
      comment = new Comment(id: 8, body: 'World')
      comment = new Comment(id: 9, body: 'Cat')
      post = new Post(commentsIds: [5,8], body: 'Hello')
      expect(post.comments.get(0).body).to.eql('Hello')
      expect(post.comments.get(1).body).to.eql('World')
      post.commentsIds = [8,9]
      expect(post.comments.get(0).body).to.eql('World')
      expect(post.comments.get(1).body).to.eql('Cat')
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
      comment = post.comments.get(1)
      expect(-> comment.confirmed = true).to.triggerEvent(post, 'change:confirmedComments')
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
      expect(-> author.set("name", "peter")).to.triggerEvent(post, "change:name", with: ["peter"])
      expect(-> author.set("email", "peter@elabs.se")).to.triggerEvent(post, "change:email", with: ["peter@elabs.se"])
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
