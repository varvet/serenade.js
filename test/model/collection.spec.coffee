require './../spec_helper'

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
    collection = @object.numbers
    expect(-> collection.push(4)).to.triggerEvent(@object.numbers_property, with: [@object.numbers, @object.numbers])

  it 'adds a count property', ->
    @object.authors = ["John", "Peter"]
    expect(@object.authorsCount).to.eql(2)
    expect(=> @object.authors.push("Harry")).to.triggerEvent(@object.authorsCount_property)
