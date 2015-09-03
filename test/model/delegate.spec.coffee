require './../spec_helper'
Serenade = require('../../lib/serenade')

describe "Serenade.Model.delegate", ->
  it "sets up delegated attributes", ->
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author"
    post = new Post(author: { name: "Jonas", email: "jonas@elabs.se" })
    expect(post.name).to.eql("Jonas")
    expect(post.email).to.eql("jonas@elabs.se")

  it "forwards other options", ->
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author", serialize: true
    post = new Post(author: { name: "Jonas", email: "jonas@elabs.se" })
    expect(post.toJSON().name).to.eql("Jonas")

  it "assigns value to delegated object when given", ->
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author"
    post = new Post(author: {})
    post.name = "Jonas"
    expect(post.author.name).to.eql("Jonas")

  it "does nothign when delegated object does not exist", ->
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author"
    post = new Post()
    post.name = "Jonas"
    expect(post.author).to.be.undefined

  it "returns undefined when the attribute being delegated to is undefined", ->
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author"
    post = new Post(author: undefined)
    expect(post.name).to.eql(undefined)
    expect(post.email).to.eql(undefined)

  it "notifies of changes when delegated attributes are changed", ->
    author = Serenade(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author"
      @property "author"
    post = new Post(author: author)
    post["~name"].trigger()
    post["~email"].trigger()
    expect(-> author.name = "peter").to.emit(post["~name"], with: ["Jonas", "peter"])
    expect(-> author.email = "peter@elabs.se").to.emit(post["~email"], with: ["jonas@elabs.se", "peter@elabs.se"])

  it "allows dependencies to be overwritten", ->
    author = Serenade(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author", dependsOn: []
    post = new Post(author: author)
    expect(-> author.name = "peter").not.to.emit(post["~name"])

  it "can set prefix", ->
    author = Serenade(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author", prefix: true
    post = new Post(author: { name: "Jonas", email: "jonas@elabs.se" })
    expect(post.authorName).to.eql("Jonas")
    expect(post.authorEmail).to.eql("jonas@elabs.se")

  it "can set suffix", ->
    author = Serenade(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author", suffix: true
    post = new Post(author: { name: "Jonas", email: "jonas@elabs.se" })
    expect(post.nameAuthor).to.eql("Jonas")
    expect(post.emailAuthor).to.eql("jonas@elabs.se")

  it "can set prefix as string", ->
    author = Serenade(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author", prefix: "quox"
    post = new Post(author: { name: "Jonas", email: "jonas@elabs.se" })
    expect(post.quoxName).to.eql("Jonas")
    expect(post.quoxEmail).to.eql("jonas@elabs.se")

  it "can set suffix as string", ->
    author = Serenade(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author", suffix: "Quox"
    post = new Post(author: { name: "Jonas", email: "jonas@elabs.se" })
    expect(post.nameQuox).to.eql("Jonas")
    expect(post.emailQuox).to.eql("jonas@elabs.se")
