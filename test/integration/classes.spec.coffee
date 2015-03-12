require './../spec_helper'

describe 'Classes', ->
  beforeEach ->
    @setupDom()

  it 'adds bound class when context value is true', ->
    context = { isActive: true }
    @render 'div[class:active=@isActive]', context
    expect(@body).to.have.element("div.active")

  it 'adds multiple bindings', ->
    context = { isActive: true, isSelected: true }
    @render 'div[class:active=@isActive class:selected=@isSelected]', context
    expect(@body.children[0].className).to.eql("active selected")

  it 'does not add bound class when context value is false', ->
    context = { active: false }
    @render 'div[class:active=@active]', context
    expect(@body).not.to.have.element("div.active")

  it 'updates when attribute changes', ->
    context = Serenade({ active: false })
    @render 'div[class:active=@active]', context
    expect(@body).not.to.have.element("div.active")
    context.active = true
    expect(@body).to.have.element("div.active")
    context.active = false
    expect(@body).not.to.have.element("div.active")

  it 'plays nice with class attributes and CSS like template values', ->
    context = Serenade({ active: true, status: "done" })
    @render 'div.status[class=@status class:active=@active]', context
    expect(@body.children[0].className).to.eql("active done status")
    context.status = "pending"
    expect(@body.children[0].className).to.eql("active pending status")
    context.active = false
    expect(@body.children[0].className).to.eql("pending status")

  it 'does not add same class more than once', ->
    context = Serenade({ active: false })
    @render 'div[class:active=@active]', context
    context.active = true
    context.active = true
    expect(@body.children[0].className).to.eql("active")
