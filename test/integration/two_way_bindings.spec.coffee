require './../spec_helper'
{expect} = require('chai')
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
    expect(model.name).to.eql("Test")

  it 'updates model when form is submitted if no event name is specified', ->
    model = {}
    @render 'form\n\tinput[type="text" binding=name]\n\t', model, {}
    input = @body.find('input').get(0)
    input.value = "Test"
    expect(model.name).to.eql(undefined)
    @fireEvent input.form, "submit"
    expect(model.name).to.eql("Test")

  it 'updates serenade model when event triggers', ->
    class MyModel extends Serenade.Model
      @property 'name'
    model = new MyModel()
    @render 'input[type="text" binding:keyup=name]', model, {}
    input = @body.find('input').get(0)
    input.value = "Test"
    @fireEvent input, "keyup"
    expect(model.name).to.eql("Test")

  it 'sets value of input to models value', ->
    model = {name: "My name"}
    @render 'input[type="text" binding:keyup=name]', model, {}
    input = @body.find('input').get(0)
    expect(input.value).to.eql("My name")

  it 'sets value of textarea to models value', ->
    model = {name: "My name"}
    @render 'textarea[binding:keyup=name]', model, {}
    input = @body.find('textarea').get(0)
    expect(input.value).to.eql("My name")

  it 'sets value of select box to models value', ->
    model = {name: "My name"}
    @render 'select[binding:change=name]\n\toption "My name"', model, {}
    input = @body.find('select').get(0)
    expect(input.value).to.eql("My name")

  it 'updates the value of input when model changes', ->
    class MyModel extends Serenade.Model
      @property 'name'
    model = new MyModel({name: "My name"})
    @render 'input[type="text" binding:keyup=name]', model, {}
    model.set("name", "Changed name")
    input = @body.find('input').get(0)
    expect(input.value).to.eql("Changed name")

  it 'rejects non-input elements', ->
    expect(=> @render 'div[binding:keyup=name]', {}, {}).to.throw()

  it 'rejects binding to the model itself', ->
    expect(=> @render 'input[binding:keyup=@]', {}, {}).to.throw()

  # Note: jsdom seems to set input.value to "" when we set it to undefined.
  # Actual browsers will set it to "undefined".
  it 'sets value to empty string when model property is undefined', ->
    model = {name: undefined}
    @render 'input[type="text" binding:change=name]', model
    input = @body.find("input").get(0)
    expect(input.value).to.eql("")

  it 'sets boolean value for checkboxes', ->
    model = {}
    @render 'input[type="checkbox" binding:change=active]', model, {}
    input = @body.find('input').get(0)
    input.checked = true
    @fireEvent input, "change"
    expect(model.active).to.eql(true)

  it 'updates the value of checkbox when model changes', ->
    class MyModel extends Serenade.Model
      @property 'active'
    model = new MyModel({active: false})
    @render 'input[type="checkbox" binding:change=active]', model, {}
    model.set("active", true)
    input = @body.find('input').get(0)
    expect(input.checked).to.eql(true)

  it 'sets model value if radio is checked', ->
    model = {}
    @render 'input[type="radio" value="small" binding:change=size]', model, {}
    input = @body.find('input').get(0)
    input.checked = true
    @fireEvent input, "change"
    expect(model.size).to.eql("small")

  it 'does not set model value if radio is not checked', ->
    model = {}
    @render 'input[type="radio" value="small" binding:change=size]', model, {}
    input = @body.find('input').get(0)
    @fireEvent input, "change"
    expect(model.size).to.eql(undefined)

  it 'checks radio if model value matches its value', ->
    class MyModel extends Serenade.Model
      @property 'size'
    model = new MyModel({size: "small"})
    @render 'input[type="radio" value="large" binding:change=size]', model, {}
    model.set("size", "large")
    input = @body.find('input').get(0)
    expect(input.checked).to.eql(true)

  it 'unchecks radio if model value does not match its value', ->
    class MyModel extends Serenade.Model
      @property 'size'
    model = new MyModel({size: "small"})
    @render 'input[type="radio" value="large" binding:change=size]', model, {}
    model.set("size", "medium")
    input = @body.find('input').get(0)
    expect(input.checked).to.eql(false)
