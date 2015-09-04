require './../spec_helper'
Serenade = require('../../lib/serenade')

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

    context["@counter"].trigger()
    @render "input[property:disabled=@counter]", context
    expect(counter).to.eql(2)
    context.counter = true
    expect(counter).to.eql(3)
    context.counter = false
    expect(counter).to.eql(4)

  it 'can set several property bindings', ->
    context = Serenade(disabled: true, checked: true)
    @render 'input[type="checkbox" property:disabled=@disabled property:checked=@checked]', context
    input = @body.querySelector("input")
    expect(input.checked).to.eql(true)
    expect(input.disabled).to.eql(true)
    context.disabled = false
    expect(input.checked).to.eql(true)
    expect(input.disabled).to.eql(false)
    context.checked = false
    expect(input.checked).to.eql(false)
    expect(input.disabled).to.eql(false)
