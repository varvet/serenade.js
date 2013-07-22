require './../spec_helper'

describe 'Memory management', ->
  beforeEach ->
    @setupDom()

  it 'prevents memory leaks on if statements', ->
    model = Serenade(leaking: true, toggle: true)
    @render '''
      div
        - if @toggle
          div
            - if @leaking
              p "test"
    ''', model
    model.toggle = false
    expect(model.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on unless statements', ->
    model = Serenade(leaking: true, toggle: true)
    @render '''
      div
        - if @toggle
          div
            - unless @leaking
              p "test"
    ''', model
    model.toggle = false
    expect(model.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on in statements', ->
    model = Serenade(leaking: true, toggle: true)
    @render '''
      div
        - if @toggle
          div
            - in @leaking
              p "test"
    ''', model
    model.toggle = false
    expect(model.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on collection statements', ->
    model = Serenade(leaking: new Serenade.Collection([]), toggle: true)
    @render '''
      div
        - if @toggle
          div
            - collection @leaking
              p "test"
    ''', model
    model.toggle = false
    for callback, list of model.leaking._callbacks
      expect(list.length).to.eql(0)

  it 'prevents memory leaks on collections when entire collection is swapped', ->
    leaking = new Serenade.Collection()
    model = Serenade(leaking: leaking)
    @render '''
      div
        - collection @leaking
          p "test"
    ''', model
    model.leaking = new Serenade.Collection()
    expect(leaking.change.listeners.length).to.eql(0)

  it 'prevents memory leaks on text nodes', ->
    model = Serenade(leaking: "foobar", toggle: true)
    @render '''
      div
        - if @toggle
          p @leaking
    ''', model
    model.toggle = false
    expect(model.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on nodes in views', ->
    model = Serenade(leaking: "foobar", toggle: true)
    Serenade.view "test", "p @leaking"
    @render """
      div
        - if @toggle
          - view "test"
    """, model
    model.toggle = false
    expect(model.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on attributes', ->
    model = Serenade(leaking: "foobar", toggle: true)
    @render '''
      div
        - if @toggle
          p[id=@leaking]
    ''', model
    model.toggle = false
    expect(model.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on two-way-bindings', ->
    model = Serenade(leaking: "foobar", toggle: true)
    @render '''
      div
        - if @toggle
          input[binding:change=@leaking]
    ''', model
    model.toggle = false
    expect(model.leaking_property.listeners.length).to.eql(0)

  it 'prevents memory leaks on style bindings', ->
    model = Serenade(leaking: "foobar", toggle: true)
    @render '''
      div
        - if @toggle
          input[style:color=@leaking]
    ''', model
    model.toggle = false
    expect(model.leaking_property.listeners.length).to.eql(0)

  it 'prevents global event bindings on submit from leaking', ->
    model = Serenade(leaking: "foobar", toggle: true)
    @render '''
      form
        - if @toggle
          input[binding=@leaking]
    ''', model
    @sinon.stub(Serenade.document, "removeEventListener")
    model.toggle = false
    expect(Serenade.document.removeEventListener.calledWith("submit")).to.be.ok

  it 'does not leak bindings when a view is properly disposed', ->
    model = Serenade(leaking: "foobar")
    view = Serenade.view("h1 @leaking").render(model)
    @body.appendChild(view)
    view.remove()
    expect(@body).not.to.have.element("h1")
    expect(model.leaking_property.listeners.length).to.eql(0)
