{Serenade} = require '../src/serenade'
{AjaxCollection} = require '../src/ajax_collection'

expired = ->
  now = new Date()
  new Date(now.getTime() - 20000)
fresh = ->
  now = new Date()
  new Date(now.getTime() + 20000)

describe 'Serenade.Model', ->
  afterEach ->
    Serenade.Model._identityMap = {}
    Serenade.Model._all = undefined

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

  describe '.find', ->
    beforeEach -> spyOn(Serenade.Model.prototype, 'refresh')
    it 'creates a new blank object with the given id', ->
      document = Serenade.Model.find('j123')
      expect(document.get('id')).toEqual('j123')
    it 'returns the same object if it has previously been initialized', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John')
      john1.test = true
      john2 = Serenade.Model.find('j123')
      expect(john2.test).toBeTruthy()
      expect(john2.get('name')).toEqual('John')
    context 'with refresh:always', ->
      beforeEach -> Serenade.Model.store expiration: 200000, refresh: 'always'
      it 'triggers a refresh on cache hit', ->
        new Serenade.Model(id: 'j123', name: 'John', expires: fresh())
        document = Serenade.Model.find('j123')
        expect(document.refresh).toHaveBeenCalled()
      it 'triggers a refresh on stale cache hit', ->
        new Serenade.Model(id: 'j123', name: 'John', expires: expired())
        document = Serenade.Model.find('j123')
        expect(document.refresh).toHaveBeenCalled()
      it 'triggers a refresh on cache miss', ->
        document = Serenade.Model.find('j123')
        expect(document.refresh).toHaveBeenCalled()
    context 'with refresh:stale', ->
      beforeEach -> Serenade.Model.store expiration: 200000, refresh: 'stale'
      it 'does not trigger a refresh on cache hit', ->
        new Serenade.Model(id: 'j123', name: 'John', expires: fresh())
        document = Serenade.Model.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()
      it 'triggers a refresh on stale cache hit', ->
        new Serenade.Model(id: 'j123', name: 'John', expires: expired())
        document = Serenade.Model.find('j123')
        expect(document.refresh).toHaveBeenCalled()
      it 'triggers a refresh on cache miss', ->
        document = Serenade.Model.find('j123')
        expect(document.refresh).toHaveBeenCalled()
    context 'with refresh:new', ->
      beforeEach -> Serenade.Model.store expiration: 200000, refresh: 'new'
      it 'does not trigger a refresh on cache hit', ->
        new Serenade.Model(id: 'j123', name: 'John', expires: fresh())
        document = Serenade.Model.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()
      it 'does not trigger a refresh on stale cache hit', ->
        new Serenade.Model(id: 'j123', name: 'John', expires: expired())
        document = Serenade.Model.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()
      it 'triggers a refresh on cache miss', ->
        document = Serenade.Model.find('j123')
        expect(document.refresh).toHaveBeenCalled()
    context 'with refresh:never', ->
      beforeEach -> Serenade.Model.store expiration: 200000, refresh: 'never'
      it 'does not trigger a refresh on cache hit', ->
        new Serenade.Model(id: 'j123', name: 'John', expires: fresh())
        document = Serenade.Model.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()
      it 'does not trigger a refresh on stale cache hit', ->
        new Serenade.Model(id: 'j123', name: 'John', expires: expired())
        document = Serenade.Model.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()
      it 'does not trigger a refresh on cache miss', ->
        document = Serenade.Model.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()

  describe '.all', ->
    beforeEach -> @sinon.spy(AjaxCollection.prototype, 'refresh')
    beforeEach -> @clock = @sinon.useFakeTimers()
    it 'create a new blank collection', ->
      Serenade.Model.store url: '/models'
      collection = Serenade.Model.all()
      expect(collection.url).toEqual('/models')
      expect(collection.constructor).toEqual(Serenade.Model)

    it 'returns the same collection if it has been used previously', ->
      Serenade.Model.store url: '/models'
      collection1 = Serenade.Model.all()
      collection1.test = true
      collection2 = Serenade.Model.all()
      expect(collection2.test).toBeTruthy()

    context 'with refresh:always', ->
      beforeEach -> Serenade.Model.store url: '/models', refresh: 'always', expires: 20000
      it 'triggers a refresh on cache hit', ->
        collection = Serenade.Model.all()
        @clock.tick(1200)
        collection = Serenade.Model.all()
        expect(collection.refresh.calledTwice).toBeTruthy()
      it 'triggers a refresh on stale cache hit', ->
        collection = Serenade.Model.all()
        @clock.tick(120000)
        collection = Serenade.Model.all()
        expect(collection.refresh.calledTwice).toBeTruthy()
      it 'triggers a refresh on cache miss', ->
        collection = Serenade.Model.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
    context 'with refresh:stale', ->
      beforeEach -> Serenade.Model.store url: '/models', refresh: 'stale', expires: 20000
      it 'does not trigger a refresh on cache hit', ->
        collection = Serenade.Model.all()
        @clock.tick(1200)
        collection = Serenade.Model.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
      it 'triggers a refresh on stale cache hit', ->
        collection = Serenade.Model.all()
        @clock.tick(120000)
        collection = Serenade.Model.all()
        expect(collection.refresh.calledTwice).toBeTruthy()
      it 'triggers a refresh on cache miss', ->
        collection = Serenade.Model.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
    context 'with refresh:new', ->
      beforeEach -> Serenade.Model.store url: '/models', refresh: 'new', expires: 20000
      it 'does not trigger a refresh on cache hit', ->
        collection = Serenade.Model.all()
        @clock.tick(1200)
        collection = Serenade.Model.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
      it 'does not trigger a refresh on stale cache hit', ->
        collection = Serenade.Model.all()
        @clock.tick(120000)
        collection = Serenade.Model.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
      it 'triggers a refresh on cache miss', ->
        collection = Serenade.Model.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
    context 'with refresh:never', ->
      beforeEach -> Serenade.Model.store url: '/models', refresh: 'never', expires: 20000
      it 'does not trigger a refresh on cache hit', ->
        collection = Serenade.Model.all()
        @clock.tick(1200)
        collection = Serenade.Model.all()
        expect(collection.refresh.called).toBeFalsy()
      it 'does not trigger a refresh on stale cache hit', ->
        collection = Serenade.Model.all()
        @clock.tick(120000)
        collection = Serenade.Model.all()
        expect(collection.refresh.called).toBeFalsy()
      it 'does not trigger a refresh on cache miss', ->
        collection = Serenade.Model.all()
        expect(collection.refresh.called).toBeFalsy()

  describe '.belongsTo', ->
    it 'uses the given constructor', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @belongsTo('comment', Comment)
      post = new Post(comment: { body: 'Hello' })
      expect(post.comment.constructor).toEqual(Comment)
      expect(post.comment.body).toEqual('Hello')
    it 'creates a plain object if there is no constructor given', ->
      class Post extends Serenade.Model
        @belongsTo('comment')
      post = new Post(comment: { body: 'Hello' })
      expect(post.comment.constructor).toEqual(Object)
      expect(post.comment.body).toEqual('Hello')
    it 'updates the id property as it changes', ->
      class Post extends Serenade.Model
        @belongsTo('comment')
      post = new Post(comment: { id: 5, body: 'Hello' })
      expect(post.commentId).toEqual(5)
      post.comment = id: 12
      expect(post.commentId).toEqual(12)
    it 'is updated if the id property changes', ->
      class Comment extends Serenade.Model
        @property 'body'
      class Post extends Serenade.Model
        @belongsTo('comment', Comment)
      comment1 = new Comment(id: 5, body: 'Hello')
      comment2 = new Comment(id: 12, body: 'World')
      post = new Post(commentId: 5)
      expect(post.comment.body).toEqual('Hello')
      post.commentId = 12
      expect(post.comment.body).toEqual('World')

  describe '.hasMany', ->
    it 'uses the given constructor', ->
    it 'uses the constructor given as a string', ->
    it 'creates plain objects if there is no constructor given', ->
    it 'updates the ids property as it changes', ->
    it 'is updated if the ids property changes', ->

  describe '.property', ->
    context 'with serialize with a string given', ->
      it 'will setup a setter method for that name', ->

  describe '#serialize()', ->
    it 'serializes only the id by default', ->
    it 'serializes any properties marked as serializable', ->
    it 'serializes properties with the given string as key', ->
    it 'serializes a property with the given function', ->
    it 'serializes a belongs to association', ->
    it 'serializes a has many association', ->
    it 'serializes the id of a belongs to association', ->
    it 'serializes the ids of a has many association', ->

  describe '#refresh()', ->
    it 'sets the load state to "loading"', ->
    it 'does nothing when triggered while already loading', ->
    it 'does nothing when no url is specified for store', ->
    it 'resets the expiration time', ->
    context 'with successful response', ->
      it 'sets the load state to "ready"', ->
      it 'updates the object with the given properties', ->
    context 'with server error', ->
      it 'sets the load state to "error"', ->
      it 'dispatches a global ajaxError event', ->
    context 'with timeout', ->
      it 'sets the load state to "error"', ->
      it 'dispatches a global ajaxError event', ->

  describe '#save()', ->
    it 'takes the serialized document and sends it to the server', ->
    it 'uses a POST request if the document is new', ->
    it 'uses a PUT request (via _method hack) if the document is saved', ->
    it 'sets save state to "saving"', ->
    it 'enqueues request if already saving', ->
    it 'does nothing when no url is specified for store', ->
    context 'with successful response', ->
      it 'sets the load state to "saved"', ->
      it 'updates the object with the given properties', ->
      it 'resets the expiration time if properties given', ->
      it 'does nothing when the response body is blank', ->
    context 'with server error', ->
      it 'sets the save state to "error"', ->
      it 'dispatches a global ajaxError event', ->
    context 'with timeout', ->
      it 'sets the save state to "error"', ->
      it 'dispatches a global ajaxError event', ->
