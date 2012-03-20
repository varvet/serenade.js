{Serenade} = require '../../src/serenade'

describe 'Bound attribute paths', ->
  beforeEach ->
    @setupDom()

    @model = new Serenade.Model
    @innerModel = new Serenade.Model

    @innerModel.set('attr2', 'jonas')
    @model.set('attr', @innerModel)


  it 'changes bound attributes as they are changed', ->

    @render 'div[id=@attr.attr2]', @model

    expect(@body).toHaveElement('div#jonas')
    @innerModel.set('attr2', 'peter')
    expect(@body).toHaveElement('div#peter')

    @innerModel = new Serenade.Model
    @innerModel.set('attr2', 'jonas')
    @model.set('attr', @innerModel)

    expect(@body).toHaveElement('div#jonas')

  it 'changes bound attributes as they are changed 2', ->
    @model.set('attr', undefined)
    expect(@body).not.toHaveElement('div#jonas')

  it 'builds collection from attribute path', ->
    model = {inner: { people: [{ name: 'jonas' }, { name: 'peter' }] }}

    @render '''
      ul
        - collection @inner.people
          li[id=name]
    ''', model
    expect(@body).toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')

  it 'updates a collection build from path dynamically', ->
    model = {inner: { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }}

    @render '''
      ul
        - collection @inner.people
          li[id=name]
    ''', model
    expect(@body).toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')
    model.inner.people.update([{ name: 'anders' }, { name: 'jimmy' }])
    expect(@body).not.toHaveElement('ul > li#jonas')
    expect(@body).not.toHaveElement('ul > li#peter')
    expect(@body).toHaveElement('ul > li#anders')
    expect(@body).toHaveElement('ul > li#jimmy')

  it 'removes item from collection build from path when requested', ->
    model = {inner: { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }}

    @render '''
      ul
        - collection @inner.people
          li[id=name]
    ''', model
    expect(@body).toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')
    model.inner.people.deleteAt(0)
    expect(@body).not.toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')
