require './../spec_helper'

describe 'Memory management', ->
  beforeEach ->
    @setupDom()

  it 'prevents memory leaks on if statements', ->
    context = Serenade(leaking: true, toggle: true)
    @render '''
      div
        - if @toggle
          div
            - if @leaking
              p "test"
    ''', context
    context.toggle = false
    expect(context.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on unless statements', ->
    context = Serenade(leaking: true, toggle: true)
    @render '''
      div
        - if @toggle
          div
            - unless @leaking
              p "test"
    ''', context
    context.toggle = false
    expect(context.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on in statements', ->
    context = Serenade(leaking: true, toggle: true)
    @render '''
      div
        - if @toggle
          div
            - in @leaking
              p "test"
    ''', context
    context.toggle = false
    expect(context.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on collection statements', ->
    context = Serenade(leaking: new Serenade.Collection([]), toggle: true)
    @render '''
      div
        - if @toggle
          div
            - collection @leaking
              p "test"
    ''', context
    context.toggle = false
    for callback, list of context.leaking._callbacks
      expect(list.length).to.eql(0)

  it 'prevents memory leaks on collections when entire collection is swapped', ->
    leaking = new Serenade.Collection()
    context = Serenade(leaking: leaking)
    @render '''
      div
        - collection @leaking
          p "test"
    ''', context
    context.leaking = new Serenade.Collection()
    expect(leaking.change.listeners.length).to.eql(0)

  it 'prevents memory leaks on text nodes', ->
    context = Serenade(leaking: "foobar", toggle: true)
    @render '''
      div
        - if @toggle
          p @leaking
    ''', context
    context.toggle = false
    expect(context.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on nodes in views', ->
    context = Serenade(leaking: "foobar", toggle: true)
    Serenade.template "test", "p @leaking"
    @render """
      div
        - if @toggle
          - view "test"
    """, context
    context.toggle = false
    expect(context.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on attributes', ->
    context = Serenade(leaking: "foobar", toggle: true)
    @render '''
      div
        - if @toggle
          p[id=@leaking]
    ''', context
    context.toggle = false
    expect(context.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on two-way-bindings', ->
    context = Serenade(leaking: "foobar", toggle: true)
    @render '''
      div
        - if @toggle
          input[binding:change=@leaking]
    ''', context
    context.toggle = false
    expect(context.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on style bindings', ->
    context = Serenade(leaking: "foobar", toggle: true)
    @render '''
      div
        - if @toggle
          input[style:color=@leaking]
    ''', context
    context.toggle = false
    expect(context.leaking_property.listeners.length).to.eql(0)

  it 'prevents global event bindings on submit from leaking', ->
    context = Serenade(leaking: "foobar", toggle: true)
    @render '''
      form
        - if @toggle
          input[binding=@leaking]
    ''', context
    @sinon.stub(Serenade.document, "removeEventListener")
    context.toggle = false
    expect(Serenade.document.removeEventListener.calledWith("submit")).to.be.ok

  it 'does not leak bindings when a view is properly disposed', ->
    context = Serenade(leaking: "foobar")
    view = Serenade.template("h1 @leaking").render(context)
    @body.appendChild(view)
    view.remove()
    expect(@body).not.to.have.element("h1")
    expect(context.leaking_property.listeners.length).to.eql(0)
