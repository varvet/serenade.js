{Serenade} = require "../src/serenade"

describe "Serenade", ->
  beforeEach -> @setupDom()

  describe ".view", ->
    it "registers a view object", ->
      Serenade.view("test", "h1#test")
      @body.append Serenade.render("test", {}, {})
      expect(@body).toHaveElement("h1#test")

    it "doesn't require model or controller to be given", ->
      Serenade.view("test", "h1#test")
      @body.append Serenade.render("test")
      expect(@body).toHaveElement("h1#test")

    it "can be rendered directly", ->
      @body.append Serenade.view("test", "h1#test").render()
      expect(@body).toHaveElement("h1#test")
