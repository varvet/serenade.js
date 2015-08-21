require "./spec_helper"

{Channel} = Serenade

describe "Serenade.Channel", ->
  describe ".all", ->
    it "combines multiple channels", ->
      channel1 = Channel.of(1)
      channel2 = Channel.of(2)
      channel3 = Channel.of(3)

      combined = Channel.all([channel1, channel2, channel3]).map((args) => args.join(","))

      expect(combined.value).to.equal("1,2,3")

      expect(-> channel1.emit(4)).to.emit(combined, with: "4,2,3")
      expect(-> channel2.emit(5)).to.emit(combined, with: "4,5,3")
      expect(-> channel3.emit(6)).to.emit(combined, with: "4,5,6")

  describe "#emit", ->
    it "broadcasts a new value to all subscribers in order", ->
      sum = 0
      channel = Channel.of(2)

      channel.bind((x) => sum = sum + x)
      channel.bind((x) => sum = sum * x)

      channel.emit(3)

      expect(sum).to.equal(21)

  describe "#map", ->
    it "creates a new channel which maps over the existing channel", ->
      channel = Channel.of(2)
      double = channel.map((x) => x * 2)

      expect(channel.value).to.equal(2)
      expect(double.value).to.equal(4)

      expect(-> channel.emit(3)).to.emit(double, with: 6)

      expect(channel.value).to.equal(3)
      expect(double.value).to.equal(6)

  describe "#pluck", ->
    it "creates a new channel which returns the given property", ->
      channel = Channel.of(name: "Jonas")
      names = channel.pluck("name")

      expect(names.value).to.equal("Jonas")

      expect(-> channel.emit(name: "Hanna")).to.emit(names, with: "Hanna")

      expect(names.value).to.equal("Hanna")

    it "gets value from attached channel and emits event when it changes", ->
      object = Serenade(name: "Jonas")

      channel = Channel.of(object)
      names = channel.pluck("name")

      expect(names.value).to.equal("Jonas")

      expect(-> object.name = "Eli").to.emit(names, with: "Eli")

      expect(names.value).to.equal("Eli")

    it "doesn't emit values from old objects", ->
      person1 = Serenade(name: "Jonas")
      person2 = Serenade(name: "Eli")

      channel = Channel.of(person1)
      names = channel.pluck("name")

      expect(-> channel.emit(person2)).to.emit(names, with: "Eli")
      expect(-> person1.name = "Harry").not.to.emit(names)
      expect(-> person2.name = "Fia").to.emit(names, with: "Fia")

  describe "#pluckAll", ->
    it "creates a new channel which returns the the given property of each element", ->
      channel = Channel.of([{ name: "Jonas" }, { name: "Eli" }])
      names = channel.pluckAll("name")

      expect(names.value).to.eql(["Jonas", "Eli"])
      expect(-> channel.emit([{ name: "Kim" }])).to.emit(names, with: ["Kim"])

      expect(names.value).to.eql(["Kim"])

    it "gets value from attached channel and emits event when it changes", ->
      person1 = Serenade(name: "Jonas")
      person2 = Serenade(name: "Kim")

      channel = Channel.of([person1, person2])
      names = channel.pluckAll("name")

      expect(names.value).to.eql(["Jonas", "Kim"])

      expect(-> person1.name = "Eli").to.emit(names, with: ["Eli", "Kim"])

      expect(names.value).to.eql(["Eli", "Kim"])

    it "doesn't emit values from old objects", ->
      person1 = Serenade(name: "Jonas")
      person2 = Serenade(name: "Kim")
      person3 = Serenade(name: "Fia")

      channel = Channel.of([person1, person2])
      names = channel.pluckAll("name")

      channel.emit([person3, person2])

      expect(-> person1.name = "Ville").not.to.emit(names)
      expect(-> person2.name = "Tor").to.emit(names, with: ["Fia", "Tor"])
      expect(-> person3.name = "Anna").to.emit(names, with: ["Anna", "Tor"])

      expect(names.value).to.eql(["Anna", "Tor"])
