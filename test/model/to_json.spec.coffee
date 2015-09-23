require './../spec_helper'
Serenade = require('../../lib/serenade')

describe 'Serenade.Model#toJSON', ->
  beforeEach ->
    class @Person extends Serenade.Model
      @attribute "name"
      @attribute "age"

  it 'serializes all attributes', ->
    @object = new @Person(name: "Jonas", age: 28)
    serialized = @object.toJSON()
    expect(serialized.name).to.eql("Jonas")
    expect(serialized.age).to.eql(28)
