require './../spec_helper'

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
    author = new Serenade.Model(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author"
    post = new Post(author: author)
    expect(-> author.name = "peter").to.triggerEvent(post.name_property, with: ["Jonas", "peter"])
    expect(-> author.email = "peter@elabs.se").to.triggerEvent(post.email_property, with: ["jonas@elabs.se", "peter@elabs.se"])

  it "allows dependencies to be overwritten", ->
    author = new Serenade.Model(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author", dependsOn: []
    post = new Post(author: author)
    expect(-> author.name = "peter").not.to.triggerEvent(post.name_property)

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

  it "can set prefix as string", ->
    author = new Serenade.Model(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author", prefix: "quox"
    post = new Post(author: { name: "Jonas", email: "jonas@elabs.se" })
    expect(post.quoxName).to.eql("Jonas")
    expect(post.quoxEmail).to.eql("jonas@elabs.se")

  it "can set suffix as string", ->
    author = new Serenade.Model(name: "Jonas", email: "jonas@elabs.se")
    class Post extends Serenade.Model
      @delegate "name", "email", to: "author", suffix: "Quox"
    post = new Post(author: { name: "Jonas", email: "jonas@elabs.se" })
    expect(post.nameQuox).to.eql("Jonas")
    expect(post.emailQuox).to.eql("jonas@elabs.se")

  it "forwards formatters", ->
    class Author extends Serenade.Model
      @property "email",
        format: (email) ->
          email.replace(/@/, "[at]")

    class Post extends Serenade.Model
      @delegate "email", to: "author", prefix: true

    author = new Author({ email: "jonas@elabs.se" })
    post = new Post(author: author)

    expect(post.authorEmail).to.eql("jonas@elabs.se")
    expect(Serenade.format(post, "authorEmail")).to.eql("jonas[at]elabs.se")
