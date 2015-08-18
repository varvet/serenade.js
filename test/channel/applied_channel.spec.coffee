require "../spec_helper"

{Channel} = Serenade

describe "Serenade.Channel", ->
  describe "#apply", ->
    it "creates a new channel which returns the given property", ->
      channel = Channel.of(name: "Jonas")
      names = channel.apply("name")

      expect(names.value).to.equal("Jonas")

      expect(-> channel.emit(name: "Hanna")).to.emit(names, with: "Hanna")

      expect(names.value).to.equal("Hanna")

    it "gets value from attached channel and emits event when it changes", ->
      object = Serenade(name: "Jonas")

      channel = Channel.of(object)
      names = channel.apply("name")

      expect(names.value).to.equal("Jonas")

      expect(-> object.name = "Eli").to.emit(names, with: "Eli")

      expect(names.value).to.equal("Eli")

    it "doesn't emit values from old objects", ->
      person1 = Serenade(name: "Jonas")
      person2 = Serenade(name: "Eli")

      channel = Channel.of(person1)
      names = channel.apply("name")

      expect(-> channel.emit(person2)).to.emit(names, with: "Eli")
      expect(-> person1.name = "Harry").not.to.emit(names)
      expect(-> person2.name = "Fia").to.emit(names, with: "Fia")
