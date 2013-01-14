require "./../spec_helper"

describe "Sereande.Model.selection", ->
  beforeEach ->
    class Comment extends Serenade.Model
      @property "isPublished", "deleted"
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
    expect(=> @post.comments.push({})).to.triggerEvent(@post.publishedComments_property)
    expect(=> @post.comments.push({})).to.triggerEvent(@post.deletedComments_property)

  it "updates selection when item in collection is updated", ->
    expect(=> @comment2.isPublished = false).to.triggerEvent(@post.publishedComments_property)
    expect(=> @comment2.deleted = true).to.triggerEvent(@post.deletedComments_property)

  it "adds a count property", ->
    expect(@post.publishedCommentsCount).to.eql(2)
    expect(@post.deletedCommentsCount).to.eql(2)

  it "updates count when collection is updated", ->
    expect(=> @post.comments.push({})).to.triggerEvent(@post.publishedCommentsCount_property)
    expect(=> @post.comments.push({})).to.triggerEvent(@post.deletedCommentsCount_property)

  it "updates count when item in collection is updated", ->
    expect(=> @comment2.isPublished = false).to.triggerEvent(@post.publishedCommentsCount_property)
    expect(=> @comment2.deleted = true).to.triggerEvent(@post.deletedCommentsCount_property)
