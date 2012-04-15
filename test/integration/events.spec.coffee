require './../spec_helper'
{expect} = require('chai')
{Serenade} = require '../../src/serenade'

describe 'Events', ->
  beforeEach ->
    @setupDom()

  it 'attaches an event which calls the controller action when triggered', ->
    controller = { iWasClicked: -> @clicked = true }
    @render 'div[event:click=iWasClicked]', {}, controller
    @fireEvent @body.find('div').get(0), 'click'
    expect(controller.clicked).to.be.ok
