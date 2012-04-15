require './../spec_helper'
{expect} = require('chai')
{Serenade} = require '../../src/serenade'

describe 'Basics', ->
  beforeEach ->
    @setupDom()

  it 'compiles a simple element', ->
    @render 'div'
    expect(@body).to.have.element('div')

  it 'compiles a simple element with an attribute', ->
    @render 'div[id="foo"]'
    expect(@body).to.have.element('div#foo')

  it 'compiles a simple element with attributes', ->
    @render 'div[id="foo" class="bar"]'
    expect(@body).to.have.element('div#foo.bar')

  it 'compiles a simple element with a child', ->
    @render '''
      div
        p
    '''
    expect(@body).to.have.element('div > p')

  it 'compiles a simple element with multiple children', ->
    @render '''
      div
        p
        a[href="foo"]
    '''
    expect(@body).to.have.element('div > a[href=foo]')

  it 'compiles a simple element with a text node child', ->
    @render '''
      div "Serenade"
    '''
    expect(@body).to.have.element('div:contains(Serenade)')
