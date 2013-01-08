require './../spec_helper'

describe 'Serenade.Model#toJSON', ->
  beforeEach ->
    class @Person extends Serenade.Model

  it 'serializes any properties marked as serializable', ->
    @Person.property('foo', serialize: true)
    @Person.property('barBaz', serialize: true)
    @Person.property('quox')
    @object = new @Person(foo: 23, barBaz: 'quack', quox: 'schmoo', other: 55)
    serialized = @object.toJSON()
    expect(serialized.foo).to.eql(23)
    expect(serialized.barBaz).to.eql('quack')
    expect(serialized.quox).to.not.exist
    expect(serialized.other).to.not.exist

  it 'serializes properties with the given string as key', ->
    @Person.property('foo', serialize: true)
    @Person.property('barBaz', serialize: 'bar_baz')
    @Person.property('quox')
    @object = new @Person(foo: 23, barBaz: 'quack', quox: 'schmoo', other: 55)
    serialized = @object.toJSON()
    expect(serialized.foo).to.eql(23)
    expect(serialized.bar_baz).to.eql('quack')
    expect(serialized.barBaz).to.not.exist
    expect(serialized.quox).to.not.exist
    expect(serialized.other).to.not.exist

  it 'serializes a property with the given function', ->
    @Person.property('foo', serialize: true)
    @Person.property('barBaz', serialize: -> ['bork', @foo.toUpperCase()])
    @Person.property('quox')
    @object = new @Person(foo: 'fooy')
    serialized = @object.toJSON()
    expect(serialized.foo).to.eql('fooy')
    expect(serialized.bork).to.eql('FOOY')
    expect(serialized.barBaz).to.not.exist

  it 'serializes an object which has a serialize function', ->
    @Person.property('foo', serialize: true)
    @object = new @Person(foo: { toJSON: -> 'from serialize' })
    serialized = @object.toJSON()
    expect(serialized.foo).to.eql('from serialize')

  it 'serializes an array of objects which have a serialize function', ->
    @Person.property('foo', serialize: true)
    @object = new @Person(foo: [{ toJSON: -> 'from serialize' }, {toJSON: -> 'another'}, "normal"])
    serialized = @object.toJSON()
    expect(serialized.foo[0]).to.eql('from serialize')
    expect(serialized.foo[1]).to.eql('another')
    expect(serialized.foo[2]).to.eql('normal')

  it 'serializes a Serenade.Collection by virtue of it having a serialize method', ->
    @Person.property('foo', serialize: true)
    collection = new Serenade.Collection([{ toJSON: -> 'from serialize' }, {toJSON: -> 'another'}, "normal"])
    @object = new @Person(foo: collection)
    serialized = @object.toJSON()
    expect(serialized.foo[0]).to.eql('from serialize')
    expect(serialized.foo[1]).to.eql('another')
    expect(serialized.foo[2]).to.eql('normal')
