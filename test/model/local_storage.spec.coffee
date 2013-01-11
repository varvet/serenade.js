require './../spec_helper'

describe 'Serenade.Model.localStorage', ->
  it 'does not store in local storage if local storage is not enabled', ->
    class Test extends Serenade.Model
      @property 'test', serialize: 'testing'

    test = new Test(id: 5, test: 'foo')
    expect(Serenade.Cache.retrieve(Test, 5)).to.not.exist

  it 'persists to cache on any changes if localStorage is enabled', ->
    class Test extends Serenade.Model
      @property 'test', serialize: 'testing'
      @localStorage()

    test = new Test(id: 5, test: 'foo')
    expect(Serenade.Cache.retrieve(Test, 5).test).to.eql('foo')
    test.test = 'monkey'
    expect(Serenade.Cache.retrieve(Test, 5).test).to.eql('monkey')

  context "with `on` option", ->
    it 'persists to cache when saved if "save"', ->
      class Test extends Serenade.Model
        @property 'test', serialize: 'testing'
        @localStorage(on: 'save')

      test = new Test(id: 5, test: 'foo')
      expect(Serenade.Cache.retrieve(Test, 5)).to.not.exist
      test.test = 'monkey'
      expect(Serenade.Cache.retrieve(Test, 5)).to.not.exist
      test.save()
      expect(Serenade.Cache.retrieve(Test, 5).test).to.eql('monkey')

    it 'persists to cache when saved if true', ->
      class Test extends Serenade.Model
        @collection "names", serialize: true
        @localStorage(on: 'set')

      test = new Test(id: 5, names: [{ first: "Jonas" }])
      test.names[0].first = "Peter"
      expect(Serenade.Cache.retrieve(Test, 5).names[0].first).to.eql("Jonas")
      test.save()
      expect(Serenade.Cache.retrieve(Test, 5).names[0].first).to.eql("Peter")

    it 'does not store in local storage if false', ->
      class Test extends Serenade.Model
        @localStorage(on: false)
        @property 'test', serialize: 'testing'

      test = new Test(id: 5, test: 'foo')
      expect(Serenade.Cache.retrieve(Test, 5)).to.not.exist


  context.skip "with `as` option", ->
    it 'persists to cache with ', ->
      class Test extends Serenade.Model
        @collection "names", serialize: true
        @localStorage on: "save", as: (id) -> "some-test-#{id}"

      test = new Test(id: 5, names: [{ first: "Jonas" }])

      console.log Test.name
      expect(Serenade.Cache.retrieve(Test, 5).names[0].first).to.eql("Jonas")
      expect(Serenade.Cache.retrieve(Test, 5).names[0].first).to.eql("Peter")
