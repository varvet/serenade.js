require "../spec_helper"

{Channel} = Serenade

describe "Serenade.Channel", ->
  describe "#applyAll", ->
    it "creates a new channel which returns the the given property of each element", ->
      channel = Channel.of([{ name: "Jonas" }, { name: "Eli" }])
      names = channel.applyAll("name")

      expect(names.value).to.eql(["Jonas", "Eli"])
      expect(-> channel.emit([{ name: "Kim" }])).to.emit(names, with: ["Kim"])

      expect(names.value).to.eql(["Kim"])

    it "gets value from attached channel and emits event when it changes", ->
      person1 = Serenade(name: "Jonas")
      person2 = Serenade(name: "Kim")

      channel = Channel.of([person1, person2])
      names = channel.applyAll("name")

      expect(names.value).to.eql(["Jonas", "Kim"])

      expect(-> person1.name = "Eli").to.emit(names, with: ["Eli", "Kim"])

      expect(names.value).to.eql(["Eli", "Kim"])

    it "doesn't emit values from old objects", ->
      person1 = Serenade(name: "Jonas")
      person2 = Serenade(name: "Kim")
      person3 = Serenade(name: "Fia")

      channel = Channel.of([person1, person2])
      names = channel.applyAll("name")

      channel.emit([person3, person2])

      expect(-> person1.name = "Ville").not.to.emit(names)
      expect(-> person2.name = "Tor").to.emit(names, with: ["Fia", "Tor"])
      expect(-> person3.name = "Anna").to.emit(names, with: ["Anna", "Tor"])

      expect(names.value).to.eql(["Anna", "Tor"])
