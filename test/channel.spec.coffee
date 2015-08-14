require "./spec_helper"

{Channel} = Serenade

describe "Serenade.Channel", ->
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
