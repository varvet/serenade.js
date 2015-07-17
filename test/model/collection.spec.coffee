require './../spec_helper'
Serenade = require('../../lib/serenade')

describe "Sereande.Model.collection", ->
  beforeEach ->
    class @Person extends Serenade.Model
      @collection "numbers"
      @collection "authors"

      @property 'authorNames', dependsOn: ['authors', 'authors:name']
    @object = new @Person()

  it 'is initialized to a collection', ->
    expect(@object.numbers[0]).to.not.exist
    @object.numbers.push(5)
    expect(@object.numbers[0]).to.eql(5)

  it 'updates the collection on set', ->
    @object.numbers = [1,2,3]
    expect(@object.numbers[0]).to.eql(1)

  it 'triggers a change event when collection is changed', ->
    expect(=> @object.numbers.push(4)).to.triggerEvent(@object.numbers_property)

  it 'adds a count property', ->
    @object.authors = ["John", "Peter"]
    expect(@object.authorsCount).to.eql(2)
    expect(=> @object.authors.push("Harry")).to.triggerEvent(@object.authorsCount_property)

  it 'triggers a change event in other object when collection is changed', ->
    class Page extends Serenade.Model
      @property "book"
      @property "authors", dependsOn: "book.authors", get: -> @book.authors
    @page = new Page(name: "45", book: @object)
    expect(=> @object.authors.push(4)).to.triggerEvent(@page.authors_property)
