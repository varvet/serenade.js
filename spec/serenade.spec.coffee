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

    it "works fine without a name", ->
      @body.append Serenade.view("h1#test").render()
      expect(@body).toHaveElement("h1#test")

    it "can be take models as parameters", ->
      model = { id: 'test' }
      @body.append Serenade.view("test", "h1[id=@id]").render(model)
      expect(@body).toHaveElement("h1#test")

    it "can be take controllers as parameters", ->
      tested = false
      controller = { test: -> tested = true }
      model = {}
      @body.append Serenade.view("test", "a[event:click=test]").render(model, controller)
      @fireEvent @body.find('a').get(0), 'click'
      expect(tested).toBeTruthy()
