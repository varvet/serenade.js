require './../spec_helper'
Serenade = require('../../lib/serenade')

describe 'Serenade.Model.identityMap', ->
  describe 'when true', ->
    it 'returns the same object if given the same id', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Serenade.Model(id: 'j123', age: 46)

      expect(john2.test).to.be.ok
      expect(john2.age).to.eql(46)
      expect(john2.name).to.eql('John')

    it 'returns different instances for same id on different constructors', ->
      Test1 = class Test extends Serenade.Model
      Test2 = class Test extends Serenade.Model

      john1 = new Test1(id: 'j123', name: 'John', age: 23)
      john2 = new Test2(id: 'j123', age: 46)

      expect(john1).not.to.eql(john2)
      expect(john1.age).to.eql(23)
      expect(john1.name).to.eql("John")
      expect(john2.age).to.eql(46)
      expect(john2.name).to.eql(undefined)

    it 'returns a new object when given a different id', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Serenade.Model(id: 'j456', age: 46)

      expect(john2.test).not.to.be.ok
      expect(john2.age).to.eql(46)
      expect(john2.name).to.not.exist

  describe 'when false', ->
    it 'returns a different object if given the same id', ->
      class Person extends Serenade.Model
        @identityMap: false
      john1 = new Person(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Person(id: 'j123', age: 46)

      expect(john1.test).to.be.ok
      expect(john1.age).to.eql(23)
      expect(john1.name).to.eql('John')
      expect(john2.test).not.to.be.ok
      expect(john2.age).to.eql(46)
      expect(john2.name).to.eql(undefined)
