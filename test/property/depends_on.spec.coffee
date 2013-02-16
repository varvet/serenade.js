require './../spec_helper'

{defineProperty} = Serenade

describe 'Serenade.defineProperty', ->
  beforeEach ->
    @object = {}

  describe 'dependsOn', ->
    it 'binds to dependencies', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'fullName',
        get: -> @first + " " + @last
        dependsOn: ['first', 'last']
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").to.triggerEvent(@object.fullName_property, with: ['undefined Pan', 'Peter Pan'])

    it 'does not bind to dependencies when none are given', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'fullName',
        get: -> @first + " " + @last
        dependsOn: []
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").not.to.triggerEvent(@object.fullName_property)

    it 'does not bind to dependencies when false given', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'fullName',
        get: -> @first + " " + @last
        dependsOn: false
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").not.to.triggerEvent(@object.fullName_property)

    it 'automatically discovers dependencies within the same object', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'initial', get: -> @first?[0]
      defineProperty @object, 'fullName', get: -> @initial + " " + @last
      @object.last = 'Pan'

      expect(=> @object.first = "Peter").to.triggerEvent(@object.fullName_property)
      expect(=> @object.last = "Smith").to.triggerEvent(@object.fullName_property)
      expect(=> @object.first = "John").to.triggerEvent(@object.initial_property)
      expect(=> @object.last = "Doe").not.to.triggerEvent(@object.initial_property)

    it 'binds to single dependency', ->
      defineProperty @object, 'name'
      defineProperty @object, 'reverseName',
        get: -> @name.split("").reverse().join("") if @name
        dependsOn: 'name'
      expect(=> @object.name = 'Jonas').to.triggerEvent(@object.reverseName_property, with: [undefined, 'sanoJ'])

    it 'can handle circular dependencies', ->
      defineProperty @object, 'foo', dependsOn: 'bar'
      defineProperty @object, 'bar', dependsOn: 'foo', get: -> @foo
      expect(=> @object.foo = 21).to.triggerEvent(@object.foo_property)
      expect(=> @object.foo = 22).to.triggerEvent(@object.bar_property)

    it 'can handle secondary dependencies', ->
      defineProperty @object, 'foo', dependsOn: 'quox'
      defineProperty @object, 'bar', dependsOn: ['quox'], get: -> @quox
      defineProperty @object, 'quox', dependsOn: ['bar', 'foo'], get: -> @foo
      expect(=> @object.foo = 21).to.triggerEvent(@object.foo_property, with: [undefined, 21])
      expect(=> @object.foo = 22).to.triggerEvent(@object.bar_property, with: [21, 22])
      expect(=> @object.foo = 23).to.triggerEvent(@object.quox_property, with: [22, 23])

    context "reaching into an object", ->
      it "observes changes to the property", ->
        defineProperty @object, 'name', dependsOn: 'author.name', get: -> @author.name
        defineProperty @object, 'author'
        @object.author = Serenade(name: "Jonas")
        expect(=> @object.author.name = 'test').to.triggerEvent(@object.name_property)

      it "can depend on properties which reach into other properties", ->
        defineProperty @object, 'uppityName', dependsOn: 'name', get: -> @name.toUpperCase() if @name
        defineProperty @object, 'name', dependsOn: 'author.name', get: -> @author.name
        defineProperty @object, 'author'
        @object.author = Serenade(name: "Jonas")
        expect(=> @object.author.name = 'test').to.triggerEvent(@object.uppityName_property)

      it "triggers changes when object is assigned after event is bound", ->
        defineProperty @object, 'name', dependsOn: 'author.name', get: -> @author?.name
        defineProperty @object, 'author'
        expect =>
          @object.author = Serenade(name: "Jonas")
          @object.author.name = "Kim"
        .to.triggerEvent(@object.name_property, count: 2)

      it "does not observe changes on objects which are no longer associated", ->
        defineProperty @object, 'name', dependsOn: 'author.name', get: -> @author?.name
        defineProperty @object, 'author'
        expect =>
          @object.author = Serenade(name: "Jonas")
          oldAuthor = @object.author
          @object.author = Serenade(name: "Peter")
          oldAuthor.name = "Kim"
        .to.triggerEvent(@object.name_property, count: 2)

    context "reaching into a collection", ->
      beforeEach ->
        defineProperty @object, 'authors', value: new Serenade.Collection()
        defineProperty @object, 'authorNames', dependsOn: "authors:name", get: -> @authors.map (a) -> a.name

      it "observes changes to the entire collection", ->
        newAuthor = Serenade(name: "Anders")
        expect(=> @object.authors.push(newAuthor)).to.triggerEvent(@object.authorNames_property)

      it "observes changes to each individual object", ->
        @object.authors.push(Serenade(name: "Bert"))
        author = @object.authors[0]
        expect(-> author.name = 'test').to.triggerEvent(@object.authorNames_property)

      it "is not affected by additional event listeners", ->
        @object.authorNames_property.bind -> @wasTriggered = true
        expect(=> @object.authors.push({ name: "Bert" })).to.triggerEvent(@object.authorNames_property)
        expect(@object.wasTriggered).to.be.ok

      it "observes changes to elements added after event is bound", ->
        expect =>
          @object.authors.push(Serenade(name: "Bert"))
          @object.authors[0].name = "Kim"
        .to.triggerEvent(@object.authorNames_property, count: 2)

      it "does not observe changes to elements no longer in the collcection", ->
        @object.authors.push(Serenade(name: "Bert"))
        expect =>
          oldAuthor = @object.authors[0]
          @object.authors.deleteAt(0)
          oldAuthor.name = 'test'
        .to.triggerEvent(@object.authorNames_property, count: 1)

      it "observes changes to newly assigned collections", ->
        expect =>
          @object.authors = new Serenade.Collection([Serenade(name: "Jonas")])
          @object.authors.push(Serenade(name: "Kim"))
        .to.triggerEvent(@object.authorNames_property, count: 2)

      it "no longer observes changes to old collections", ->
        oldAuthors = @object.authors
        expect =>
          @object.authors = new Serenade.Collection([Serenade(name: "Jonas")])
          oldAuthors.push(Serenade(name: "Kim"))
        .to.triggerEvent(@object.authorNames_property, count: 1)

      it "no longer observes changes to items in old collections", ->
        oldAuthors = @object.authors
        oldAuthors.push(Serenade(name: "Peter"))
        expect =>
          @object.authors = new Serenade.Collection([Serenade(name: "Jonas")])
          oldAuthors[0].name = "Kim"
        .to.triggerEvent(@object.authorNames_property, count: 1)

