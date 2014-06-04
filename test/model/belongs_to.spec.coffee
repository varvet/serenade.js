require './../spec_helper'

describe 'Serenade.Model.belongsTo', ->
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

  it 'nullifies the association when null given', ->
    class Post extends Serenade.Model
      @property 'body'
    class Comment extends Serenade.Model
      @belongsTo('post', as: -> Post)
    post = new Post(body: 'Hello')
    comment = new Comment(post: post)
    comment.post = null
    expect(comment.post).to.eql(null)

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

  it 'removes itself from its previous inverse relation when nullified', ->
    class Comment extends Serenade.Model
      @belongsTo "post", inverseOf: "comments", as: -> Post
    class Post extends Serenade.Model
      @hasMany 'comments', as: -> Comment
    post = new Post()
    comment = new Comment(post: post)
    comment.post = null
    expect(post.comments.length).to.eql(0)
    expect(comment.post).to.be.null
