{Serenade} = require '../../src/serenade'

describe 'Two-way bindings', ->
  beforeEach ->
    @setupDom()

  it 'updates plain model when event triggers', ->
    model = {}
    @render 'input[type="text" binding:keyup=name]', model, {}
    input = @body.find('input').get(0)
    input.value = "Test"
    @fireEvent input, "keyup"
    expect(model.name).toEqual("Test")

  it 'updates serenade model when event triggers', ->
    class MyModel extends Serenade.Model
      @property 'name'
    model = new MyModel()
    @render 'input[type="text" binding:keyup=name]', model, {}
    input = @body.find('input').get(0)
    input.value = "Test"
    @fireEvent input, "keyup"
    expect(model.name).toEqual("Test")