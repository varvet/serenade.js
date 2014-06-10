require './../spec_helper'

describe 'Bound properties', ->
  beforeEach ->
    @setupDom()

  it 'supports non-bound values', ->
    model = {}
    @render 'input[property:disabled="disabled"]', model
    expect(@body).to.have.element('input[disabled]')

  it 'does not add bound property if value is undefined in model', ->
    model = {}
    @render 'input[property:disabled=@foo]', model
    expect(@body).not.to.have.element('input[disabled]')

  it 'get bound properties from the model', ->
    model = { disabled: true }
    @render 'input[property:disabled=@disabled]', model
    expect(@body).to.have.element('input[disabled]')

  it 'changes bound properties as they are changed', ->
    model = Serenade(disabled: true)
    @render 'input[property:disabled=@disabled]', model
    expect(@body).to.have.element('input[disabled]')
    model.disabled = false
    expect(@body).not.to.have.element('input[disabled]')

  it 'does not access getter more than once when updating dom nodes', ->
    model = {}
    counter = 0

    Serenade.defineProperty model, "counter",
      get: ->
        counter += 1
        @_counter
      set: (value) ->
        @_counter = value

    model.counter_property.trigger()
    @render "input[property:disabled=@counter]", model
    expect(counter).to.eql(2)
    model.counter = true
    expect(counter).to.eql(3)
    model.counter = false
    expect(counter).to.eql(4)

  it 'can set several property bindings', ->
    model = Serenade(disabled: true, checked: true)
    @render 'input[type="checkbox" property:disabled=@disabled property:checked=@checked]', model
    expect(@body).to.have.element('input[disabled][checked]')
    model.disabled = false
    expect(@body).not.to.have.element('input[disabled][checked]')
    expect(@body).to.have.element('input[checked]')
    model.checked = false
    expect(@body).not.to.have.element('input[checked]')
    expect(@body).to.have.element('input')
