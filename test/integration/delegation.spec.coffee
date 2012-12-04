require './../spec_helper'
{expect} = require('chai')
{Serenade} = require '../../src/serenade'

describe 'Delegation', ->
  beforeEach ->
    @setupDom()

  it 'updates a delegated property', ->
    deleg1 = { name: 'jonas' }
    deleg2 = { name: 'peter' }
    class M extends Serenade.Model
      @property 'inner'
      @delegate 'name', to: 'inner'
    model = new M({ inner: deleg1 })
    @render '''
      span[id=name]
    ''', model
    expect(@body).to.have.element('span#jonas')
    model.inner = deleg2
    expect(@body).not.to.have.element('span#jonas')
    expect(@body).to.have.element('span#peter')

  it 'updates a delegated collection', ->
    deleg1 = { people: [{ name: 'jonas' }] }
    deleg2 = { people: [{ name: 'peter' }] }
    class M extends Serenade.Model
      @property 'inner'
      @delegate 'people', to: 'inner'
    model = new M({ inner: deleg1 })
    @render '''
      ul
        - collection "people"
          li[id=name]
    ''', model
    expect(@body).to.have.element('ul > li#jonas')
    model.inner = deleg2
    expect(@body).not.to.have.element('ul > li#jonas')
    expect(@body).to.have.element('ul > li#peter')
