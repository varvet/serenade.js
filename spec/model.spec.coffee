{Serenade} = require '../src/serenade'
{Cache} = require '../src/cache'

describe 'Serenade.Model', ->
  describe '#constructor', ->
    it 'sets the given properties', ->
      john = new Serenade.Model(name: 'John', age: 23)
      expect(john.get('age')).toEqual(23)
      expect(john.get('name')).toEqual('John')

    it 'returns the same object if given the same id', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Serenade.Model(id: 'j123', age: 46)

      expect(john2.test).toBeTruthy()
      expect(john2.get('age')).toEqual(46)
      expect(john2.get('name')).toEqual('John')

    it 'returns a new object when given a different id', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Serenade.Model(id: 'j456', age: 46)

      expect(john2.test).toBeFalsy()
      expect(john2.get('age')).toEqual(46)
      expect(john2.get('name')).toBeUndefined()

    it 'does not store in local storage if local storage is false', ->
      class Test extends Serenade.Model
        @property 'test', serialize: 'testing'

      test = new Test(id: 5, test: 'foo')
      expect(Cache.retrieve(Test, 5)).toBeUndefined()

    it 'binds sets the cache on any changes if localStorage is true', ->
      class Test extends Serenade.Model
        @property 'test', serialize: 'testing'
        @localStorage = true

      test = new Test(id: 5, test: 'foo')
      expect(Cache.retrieve(Test, 5).test).toEqual('foo')
      test.set('test', 'monkey')
      expect(Cache.retrieve(Test, 5).test).toEqual('monkey')

    it 'binds a sets the cache only when saved if localStorage is "save"', ->
      class Test extends Serenade.Model
        @property 'test', serialize: 'testing'
        @localStorage = 'save'

      test = new Test(id: 5, test: 'foo')
      expect(Cache.retrieve(Test, 5)).toBeUndefined()
      test.set('test', 'monkey')
      expect(Cache.retrieve(Test, 5)).toBeUndefined()
      test.save()
      expect(Cache.retrieve(Test, 5).test).toEqual('monkey')

  describe '.extend', ->
    it 'sets the name of the class', ->
      Test = Serenade.Model.extend('Testing')
      expect(Test.modelName).toEqual('Testing')
    it 'sets up prototypes correctly', ->
      Test = Serenade.Model.extend('Testing')
      test = new Test(foo: 'bar')
      expect(test.get('foo')).toEqual('bar')
    it 'copies over class variables', ->
      Test = Serenade.Model.extend('Testing')
      expect(typeof Test.hasMany).toEqual('function')
    it 'runs the provided constructor function', ->
      Test = Serenade.Model.extend('Testing', -> @foo = true)
      test = new Test()
      expect(test.foo).toBeTruthy()

  describe '.find', ->
    it 'creates a new blank object with the given id', ->
      document = Serenade.Model.find('j123')
      expect(document.get('id')).toEqual('j123')
    it 'returns the same object if it has previously been initialized', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John')
      john1.test = true
      john2 = Serenade.Model.find('j123')
      expect(john2.test).toBeTruthy()
      expect(john2.get('name')).toEqual('John')

  describe '.belongsTo', ->
    it 'allows model to be assigned and retrieved', ->
      class Post extends Serenade.Model
        @property 'body'
      class Comment extends Serenade.Model
        @belongsTo('post', as: -> Post)
      post = new Post(body: 'Hello')
      comment = new Comment(post: post)
      expect(comment.post).toEqual(post)
    it 'uses the given constructor when assigning to attributes', ->
      class Post extends Serenade.Model
        @property 'body'
      class Comment extends Serenade.Model
        @belongsTo('post', as: -> Post)
      comment = new Comment(post: { body: 'Hello' })
      expect(comment.post.constructor).toEqual(Post)
      expect(comment.post.body).toEqual('Hello')
    it 'creates a plain object if there is no constructor given', ->
      class Comment extends Serenade.Model
        @belongsTo('post')
      comment = new Comment(post: { body: 'Hello' })
      expect(comment.post.constructor).toEqual(Object)
      expect(comment.post.body).toEqual('Hello')
    it 'updates the id property as it changes', ->
      class Comment extends Serenade.Model
        @belongsTo('post')
      comment = new Comment(post: { id: 5, body: 'Hello' })
      expect(comment.postId).toEqual(5)
      comment.post = id: 12
      expect(comment.postId).toEqual(12)
    it 'is updated if the id property changes', ->
      class Post extends Serenade.Model
        @property 'body'
      class Comment extends Serenade.Model
        @belongsTo('post', as: -> Post)
      post1 = new Post(id: 5, body: 'Hello')
      post2 = new Post(id: 12, body: 'World')
      comment = new Comment(postId: 5)
      expect(comment.post.body).toEqual('Hello')
      comment.postId = 12
      expect(comment.post.body).toEqual('World')
    it 'serializes the entire associated document', ->
      class Post extends Serenade.Model
        @property 'body', serialize: true
      class Comment extends Serenade.Model
        @belongsTo('post', serialize: true, as: -> Post)
      comment = new Comment(post: { body: "foo" })
      expect(comment.serialize().post.body).toEqual("foo")
    it 'serializes the id', ->
      class Post extends Serenade.Model
        @property 'body', serialize: true
      class Comment extends Serenade.Model
        @belongsTo('post', serializeId: true, as: -> Post)
      comment = new Comment(post: { id: 5, body: "foo" })
      expect(comment.serialize().postId).toEqual(5)

  describe '.hasMany', ->
    it 'allows objects to be added and retrieved', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
      comment1 = new Comment(body: 'Hello')
      comment2 = new Comment(body: 'Monkey')
      post = new Post(comments: [comment1, comment2])
      expect(post.comments.get(0)).toEqual(comment1)
      expect(post.comments.get(1)).toEqual(comment2)
    it 'uses the given constructor', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
      post = new Post(comments: [{ body: 'Hello' }, { body: 'Monkey' }])
      expect(post.comments.get(0).constructor).toEqual(Comment)
      expect(post.comments.get(1).constructor).toEqual(Comment)
      expect(post.comments.get(0).body).toEqual('Hello')
      expect(post.comments.get(1).body).toEqual('Monkey')
    it 'creates plain objects if there is no constructor given', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @hasMany 'comments'
      post = new Post(comments: [{ body: 'Hello' }, { body: 'Monkey' }])
      expect(post.comments.get(0).constructor).toEqual(Object)
      expect(post.comments.get(1).constructor).toEqual(Object)
      expect(post.comments.get(0).body).toEqual('Hello')
      expect(post.comments.get(1).body).toEqual('Monkey')
    it 'updates the ids property as it changes', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
      post = new Post(comments: [{ id: 4 }, { id: 3 }])
      expect(post.commentsIds.get(0)).toEqual(4)
      expect(post.commentsIds.get(1)).toEqual(3)
      post.comments = [{id: 12}]
      expect(post.commentsIds.get(0)).toEqual(12)
      expect(post.commentsIds.get(1)).toBeUndefined()
    it 'is updated if the ids property changes', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
      comment = new Comment(id: 5, body: 'Hello')
      comment = new Comment(id: 8, body: 'World')
      comment = new Comment(id: 9, body: 'Cat')
      post = new Post(commentsIds: [5,8], body: 'Hello')
      expect(post.comments.get(0).body).toEqual('Hello')
      expect(post.comments.get(1).body).toEqual('World')
      post.commentsIds = [8,9]
      expect(post.comments.get(0).body).toEqual('World')
      expect(post.comments.get(1).body).toEqual('Cat')
    it 'serializes the entire associated documents', ->
      class Comment extends Serenade.Model
        @property 'body', serialize: true
      class Post extends Serenade.Model
        @hasMany 'comments', serialize: true, as: -> Comment
      post = new Post(comments: [{ body: 'Hello' }, { body: 'Monkey' }])
      serialized = post.serialize()
      expect(serialized.comments[0].body).toEqual('Hello')
      expect(serialized.comments[1].body).toEqual('Monkey')
    it 'serializes the ids', ->
      class Comment extends Serenade.Model
        @property 'body', serialize: true
      class Post extends Serenade.Model
        @hasMany 'comments', serializeIds: true, as: -> Comment
      post = new Post(comments: [{ id: 5, body: 'Hello' }, { id: 8, body: 'Monkey' }])
      serialized = post.serialize()
      expect(serialized.commentsIds[0]).toEqual(5)
      expect(serialized.commentsIds[1]).toEqual(8)
    it 'can observe changes to items in the collection', ->
      class Comment extends Serenade.Model
        @property 'confirmed'
      class Post extends Serenade.Model
        @hasMany 'comments', as: -> Comment
        @property 'confirmedComments', dependsOn: 'comments.confirmed'
      post = new Post(name: "test")
      post.comments = [{ id: 5, body: 'Hello', confirmed: true }, { id: 8, body: 'Monkey', confirmed: false }]
      post.comments.get(1).confirmed = true
      expect(post).toHaveReceivedEvent('change:confirmedComments')