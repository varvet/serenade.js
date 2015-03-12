require './../spec_helper'

describe 'Bound properties', ->
  beforeEach ->
    @setupDom()

  it 'supports non-bound values', ->
    context = {}
    @render 'input[property:disabled="disabled"]', context
    expect(@body).to.have.element('input[disabled]')

  it 'does not add bound property if value is undefined in context', ->
    context = {}
    @render 'input[property:disabled=@foo]', context
    expect(@body).not.to.have.element('input[disabled]')

  it 'get bound properties from the context', ->
    context = { disabled: true }
    @render 'input[property:disabled=@disabled]', context
    expect(@body).to.have.element('input[disabled]')

  it 'changes bound properties as they are changed', ->
    context = Serenade(disabled: true)
    @render 'input[property:disabled=@disabled]', context
    expect(@body).to.have.element('input[disabled]')
    context.disabled = false
    expect(@body).not.to.have.element('input[disabled]')

  it 'does not access getter more than once when updating dom nodes', ->
    context = {}
    counter = 0

    Serenade.defineProperty context, "counter",
      get: ->
        counter += 1
        @_counter
      set: (value) ->
        @_counter = value

    context.counter_property.trigger()
    @render "input[property:disabled=@counter]", context
    expect(counter).to.eql(2)
    context.counter = true
    expect(counter).to.eql(3)
    context.counter = false
    expect(counter).to.eql(4)

  it 'can set several property bindings', ->
    context = Serenade(disabled: true, checked: true)
    @render 'input[type="checkbox" property:disabled=@disabled property:checked=@checked]', context
    expect(@body).to.have.element('input[disabled][checked]')
    context.disabled = false
    expect(@body).not.to.have.element('input[disabled][checked]')
    expect(@body).to.have.element('input[checked]')
    context.checked = false
    expect(@body).not.to.have.element('input[checked]')
    expect(@body).to.have.element('input')
