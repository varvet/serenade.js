require "./../spec_helper"

describe "Sereande.Model.selection", ->
  beforeEach ->
    class Comment extends Serenade.Model
      @properties "isPublished", "deleted"
    class Post extends Serenade.Model
      @hasMany "comments", as: -> Comment

      @selection "publishedComments", from: "comments", filter: "isPublished"
      @selection "deletedComments", from: "comments", filter: "deleted"

    @comment1 = new Comment(isPublished: true, deleted: true)
    @comment2 = new Comment(isPublished: true, deleted: false)
    @comment3 = new Comment(isPublished: false, deleted: true)

    @post = new Post(comments: [@comment1, @comment2, @comment3])

  it "filters an existing collection", ->
    expect(@post.publishedComments.toArray()).to.eql([@comment1, @comment2])
    expect(@post.deletedComments.toArray()).to.eql([@comment1, @comment3])

  it "updates selection when collection is updated", ->
    expect(=> @post.comments.push({})).to.triggerEvent(@post.change_publishedComments)
    expect(=> @post.comments.push({})).to.triggerEvent(@post.change_deletedComments)

  it "updates selection when item in collection is updated", ->
    expect(=> @comment2.isPublished = false).to.triggerEvent(@post.change_publishedComments)
    expect(=> @comment2.deleted = true).to.triggerEvent(@post.change_deletedComments)

  it "adds a count property", ->
    expect(@post.publishedCommentsCount).to.eql(2)
    expect(@post.deletedCommentsCount).to.eql(2)

  it "updates count when collection is updated", ->
    expect(=> @post.comments.push({})).to.triggerEvent(@post.change_publishedCommentsCount)
    expect(=> @post.comments.push({})).to.triggerEvent(@post.change_deletedCommentsCount)

  it "updates count when item in collection is updated", ->
    expect(=> @comment2.isPublished = false).to.triggerEvent(@post.change_publishedCommentsCount)
    expect(=> @comment2.deleted = true).to.triggerEvent(@post.change_deletedCommentsCount)
