require './../spec_helper'
Serenade = require('../../lib/serenade')

describe 'Bound attributes and text nodes', ->
  beforeEach ->
    @setupDom()

  it 'filters bound attributes through global helper', ->
    context = { height: 123 }
    @render 'div[style:height=px(height)]', context
    expect(@body.querySelector('div').style.height).to.equal("123px")
