require "./../spec_helper"

describe "Sereande.Model.selection", ->
  beforeEach ->
    class Comment extends Serenade.Model
      @property "isPublished", "deleted", "message"
    class Post extends Serenade.Model
      @hasMany "comments", as: -> Comment

      @selection "publishedComments", from: "comments", filter: "isPublished"
      @selection "deletedComments", from: "comments", filter: "deleted", serialize: true

      @selection "commentMessages", from: "comments", map: "message"
      @selection "publishedCommentMessages", filter: "isPublished", from: "comments", map: "message"
      @selection "upcasedMessages", from: "comments", map: (c) -> c.message.toUpperCase()

      @selection "activeComments", from: "comments", filter: (c) -> c.isPublished and not c.deleted

    @comment1 = new Comment(message: "Cool", isPublished: true, deleted: true)
    @comment2 = new Comment(message: "Dude", isPublished: true, deleted: false)
    @comment3 = new Comment(message: "Sick", isPublished: false, deleted: true)

    @post = new Post(comments: [@comment1, @comment2, @comment3])

  it "filters an existing collection", ->
    expect(@post.publishedComments.toArray()).to.eql([@comment1, @comment2])
    expect(@post.deletedComments.toArray()).to.eql([@comment1, @comment3])

  it "maps an existing collection", ->
    expect(@post.commentMessages.toArray()).to.eql(["Cool", "Dude", "Sick"])

  it "maps with function", ->
    expect(@post.upcasedMessages.toArray()).to.eql(["COOL", "DUDE", "SICK"])

  it "filters with function", ->
    expect(@post.activeComments.toArray()).to.eql([@comment2])

  it "can combine map and filter", ->
    expect(@post.publishedCommentMessages.toArray()).to.eql(["Cool", "Dude"])

  it "allows other options to be forwarded", ->
    expect(@post.toJSON().deletedComments).to.be.ok

  it "updates selection when collection is updated", ->
    expect(=> @post.comments.push({ message: "w00t" })).to.triggerEvent(@post.publishedComments_property, count: 2)
    expect(=> @post.comments.push({ message: "w00t" })).to.triggerEvent(@post.deletedComments_property, count: 2)
    expect(=> @post.comments.push({ message: "w00t" })).to.triggerEvent(@post.commentMessages_property, count: 2)
    expect(=> @post.comments.push({ message: "w00t" })).to.triggerEvent(@post.upcasedMessages_property, count: 2)
    expect(=> @post.comments.push({ message: "w00t" })).to.triggerEvent(@post.activeComments_property, count: 2)

  it "updates selection when item in collection is updated", ->
    expect(=> @comment2.isPublished = false).to.triggerEvent(@post.publishedComments_property)
    expect(=> @comment2.deleted = true).to.triggerEvent(@post.deletedComments_property)
    expect(=> @comment2.message = "tada").to.triggerEvent(@post.commentMessages_property)

  it "does not update selection with function when item in collection is updated", ->
    expect(=> @comment2.deleted = true).not.to.triggerEvent(@post.activeComments_property)
    expect(=> @comment2.message = "tada").not.to.triggerEvent(@post.upcasedMessages_property)

  it "adds a count property", ->
    expect(@post.publishedCommentsCount).to.eql(2)
    expect(@post.deletedCommentsCount).to.eql(2)

  it "updates count when collection is updated", ->
    expect(=> @post.comments.push({ message: "w00t", isPublished: true })).to.triggerEvent(@post.publishedCommentsCount_property)
    expect(=> @post.comments.push({ message: "w00t", deleted: true })).to.triggerEvent(@post.deletedCommentsCount_property)

  it "updates count when item in collection is updated", ->
    expect(=> @comment2.isPublished = false).to.triggerEvent(@post.publishedCommentsCount_property)
    expect(=> @comment2.deleted = true).to.triggerEvent(@post.deletedCommentsCount_property)
