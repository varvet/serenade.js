require './../spec_helper'
Serenade = require('../../lib/serenade')

describe 'Bound attributes and text nodes', ->
  beforeEach ->
    @setupDom()

  it 'filters bound attributes through global helper', ->
    context = { height: 123 }
    @render 'div[style:height=px(height)]', context
    expect(@body.querySelector('div').style.height).to.equal("123px")

  it 'filters updates attribute when any value changes', ->
    context = Serenade(name: "Jonas", age: 29)
    @render 'div[title=coalesce(@name @age)]', context
    expect(@body.querySelector('div').title).to.equal("Jonas 29")
    context.name = "Peter"
    expect(@body.querySelector('div').title).to.equal("Peter 29")
    context.age = 30
    expect(@body.querySelector('div').title).to.equal("Peter 30")

  it 'can nest filters', ->
    context = Serenade(name: "Jonas", age: 29)
    @render 'div[title=coalesce(toUpperCase(@name) @age)]', context
    expect(@body.querySelector('div').title).to.equal("JONAS 29")
    context.name = "Peter"
    expect(@body.querySelector('div').title).to.equal("PETER 29")
    context.age = 30
    expect(@body.querySelector('div').title).to.equal("PETER 30")
