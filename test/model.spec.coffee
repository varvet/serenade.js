require './spec_helper'
{Serenade} = require '../src/serenade'
{Cache} = require '../src/cache'
{expect} = require('chai')

describe 'Serenade.Model', ->
  describe '#constructor', ->
    it 'sets the given properties', ->
      john = new Serenade.Model(name: 'John', age: 23)
      expect(john.age).to.eql(23)
      expect(john.name).to.eql('John')

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

    it 'does not store in local storage if local storage is false', ->
      class Test extends Serenade.Model
        @property 'test', serialize: 'testing'

      test = new Test(id: 5, test: 'foo')
      expect(Cache.retrieve(Test, 5)).to.not.exist

    it 'persists to cache on any changes if localStorage is true', ->
      class Test extends Serenade.Model
        @property 'test', serialize: 'testing'
        @localStorage = true

      test = new Test(id: 5, test: 'foo')
      expect(Cache.retrieve(Test, 5).test).to.eql('foo')
      test.test = 'monkey'
      expect(Cache.retrieve(Test, 5).test).to.eql('monkey')

    it 'persists to cache when saved if localStorage is "save"', ->
      class Test extends Serenade.Model
        @property 'test', serialize: 'testing'
        @localStorage = 'save'

      test = new Test(id: 5, test: 'foo')
      expect(Cache.retrieve(Test, 5)).to.not.exist
      test.test = 'monkey'
      expect(Cache.retrieve(Test, 5)).to.not.exist
      test.save()
      expect(Cache.retrieve(Test, 5).test).to.eql('monkey')

    it 'persists to cache when saved if localStorage is true', ->
      class Test extends Serenade.Model
        @collection "names", serialize: true
        @localStorage = true

      test = new Test(id: 5, names: [{ first: "Jonas" }])
      test.names[0].first = "Peter"
      expect(Cache.retrieve(Test, 5).names[0].first).to.eql("Jonas")
      test.save()
      expect(Cache.retrieve(Test, 5).names[0].first).to.eql("Peter")

  describe '.extend', ->
    it 'sets up prototypes correctly', ->
      Test = Serenade.Model.extend()
      test = new Test(foo: 'bar')
      expect(test.foo).to.eql('bar')
    it 'copies over class variables', ->
      Test = Serenade.Model.extend()
      expect(typeof Test.hasMany).to.eql('function')
    it 'runs the provided constructor function', ->
      Test = Serenade.Model.extend(-> @foo = true)
      test = new Test()
      expect(test.foo).to.be.ok
    it 'works with the identity map', ->
      Person = Serenade.Model.extend()
      john1 = new Person(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Person(id: 'j123', age: 46)

      expect(john2.test).to.be.ok
      expect(john2.age).to.eql(46)
      expect(john2.name).to.eql('John')

  describe '.uniqueId', ->
    it 'is different for different classes', ->
      Test1 = class Test extends Serenade.Model
      Test2 = class Test extends Serenade.Model
      expect(Test1.uniqueId()).not.to.eql(Test2.uniqueId())
    it 'returns the same results when called multiple times', ->
      Test = class Test extends Serenade.Model
      expect(Test.uniqueId()).to.eql(Test.uniqueId())
    it 'is different for subclasses', ->
      Test1 = class Test extends Serenade.Model
      Test1.uniqueId()
      Test2 = class Test extends Test1
      expect(Test1.uniqueId()).not.to.eql(Test2.uniqueId())

  describe '.find', ->
    it 'creates a new blank object with the given id', ->
      document = Serenade.Model.find('j123')
      expect(document.id).to.eql('j123')
    it 'returns the same object if it has previously been initialized', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John')
      john1.test = true
      john2 = Serenade.Model.find('j123')
      expect(john2.test).to.be.ok
      expect(john2.name).to.eql('John')
