require './../spec_helper'

describe 'Two-way bindings', ->
  beforeEach ->
    @setupDom()

  it 'updates plain context when event triggers', ->
    context = {}
    @render 'input[type="text" binding:keyup=@name]', context, {}
    input = @body.querySelector('input')
    input.value = "Test"
    @fireEvent input, "keyup"
    expect(context.name).to.eql("Test")

  it 'updates context when form is submitted if no event name is specified', ->
    context = {}
    @render 'form\n\tinput[type="text" binding=@name]\n\t', context, {}
    input = @body.querySelector('input')
    input.value = "Test"
    expect(context.name).to.eql(undefined)
    @fireEvent input.form, "submit"
    expect(context.name).to.eql("Test")

  it 'is triggered before form submits', ->
    stored = null
    context =
      store: -> stored = context.name
    @render """
      form[event:submit=store!]
        input[type="text" binding=@name]
    """, context
    input = @body.querySelector('input')
    input.value = "Test"
    @fireEvent input.form, "submit"
    expect(stored).to.eql("Test")

  it 'updates serenade context when event triggers', ->
    class MyModel extends Serenade.Model
      @property 'name'
    context = new MyModel()
    @render 'input[type="text" binding:keyup=@name]', context, {}
    input = @body.querySelector('input')
    input.value = "Test"
    @fireEvent input, "keyup"
    expect(context.name).to.eql("Test")

  it 'sets value of input to context value', ->
    context = {name: "My name"}
    @render 'input[type="text" binding:keyup=@name]', context, {}
    input = @body.querySelector('input')
    expect(input.value).to.eql("My name")

  it 'sets value of textarea to context value', ->
    context = {name: "My name"}
    @render 'textarea[binding:keyup=@name]', context, {}
    input = @body.querySelector('textarea')
    expect(input.value).to.eql("My name")

  it "sets value of select box to context's value", ->
    context = {name: "My name"}
    @render """
      select[binding:change=name]
        option "Other name"
        option "My name"
    """, context, {}
    input = @body.querySelector('select')
    expect(input.value).to.eql("My name")

  it 'updates the value of input when context changes', ->
    class MyModel extends Serenade.Model
      @property 'name'
    context = new MyModel({name: "My name"})
    @render 'input[type="text" binding:keyup=@name]', context, {}
    context.name = "Changed name"
    input = @body.querySelector('input')
    expect(input.value).to.eql("Changed name")

  it 'rejects non-input elements', ->
    expect(=> @render 'div[binding:keyup=@name]', {}, {}).to.throw()

  it 'rejects binding to the context itself', ->
    expect(=> @render 'input[binding:keyup=@]', {}, {}).to.throw()

  # Note: jsdom seems to set input.value to "" when we set it to undefined.
  # Actual browsers will set it to "undefined".
  it 'sets value to empty string when context property is undefined', ->
    context = {name: undefined}
    @render 'input[type="text" binding:change=@name]', context
    input = @body.querySelector("input")
    expect(input.value).to.eql("")

  it 'sets boolean value for checkboxes', ->
    context = {}
    @render 'input[type="checkbox" binding:change=@active]', context, {}
    input = @body.querySelector('input')
    input.checked = true
    @fireEvent input, "change"
    expect(context.active).to.eql(true)

  it 'updates the value of checkbox when context changes', ->
    class MyModel extends Serenade.Model
      @property 'active'
    context = new MyModel({active: false})
    @render 'input[type="checkbox" binding:change=@active]', context, {}
    context.active = true
    input = @body.querySelector('input')
    expect(input.checked).to.eql(true)

  it 'sets context value if radio is checked', ->
    context = {}
    @render 'input[type="radio" value="small" binding:change=@size]', context, {}
    input = @body.querySelector('input')
    input.checked = true
    @fireEvent input, "change"
    expect(context.size).to.eql("small")

  it 'does not set context value if radio is not checked', ->
    context = {}
    @render 'input[type="radio" value="small" binding:change=@size]', context, {}
    input = @body.querySelector('input')
    @fireEvent input, "change"
    expect(context.size).to.eql(undefined)

  it 'checks radio if context value matches its value', ->
    class MyModel extends Serenade.Model
      @property 'size'
    context = new MyModel({size: "small"})
    @render 'input[type="radio" value="large" binding:change=@size]', context, {}
    context.size =  "large"
    input = @body.querySelector('input')
    expect(input.checked).to.eql(true)

  it 'unchecks radio if context value does not match its value', ->
    class MyModel extends Serenade.Model
      @property 'size'
    context = new MyModel({size: "small"})
    @render 'input[type="radio" value="large" binding:change=@size]', context, {}
    context.size = "medium"
    input = @body.querySelector('input')
    expect(input.checked).to.eql(false)
