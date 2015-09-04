require './../spec_helper'
Serenade = require('../../lib/serenade')

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
      @property 'confirmedComments', dependsOn: 'comments:confirmed', get: -> @comments.filter (c) -> c.confirmed
    post = new Post(name: "test")
    post.confirmedComments
    post.comments = [{ id: 5, body: 'Hello', confirmed: true }, { id: 8, body: 'Monkey', confirmed: false }]
    comment = post.comments[1]
    expect(-> comment.confirmed = true).to.emit(post["@confirmedComments"])

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

  it 'adds a count property', ->
    class Post extends Serenade.Model
      @hasMany 'comments'
    post = new Post()
    post.comments = [{ body: "Hello" }, { body: "World" }]
    expect(post.commentsCount).to.eql(2)
    expect(-> post.comments.push({ body: "Test" })).to.emit(post["@commentsCount"])
