require './spec_helper'
{Transform} = require '../lib/transform'

replay = (array, operations) ->
  array = [].concat(array)
  for operation in operations
    switch operation.type
      when "insert"
        array.splice(operation.index, 0, operation.value)
      when "remove"
        array.splice(operation.index, 1)
      when "swap"
        from = operation.index
        to = operation.with
        [array[from], array[to]] = [array[to], array[from]]
  array

describe 'Serenade.Transform', ->
  it "transforms arrays into each other", ->
    iterations = 10
    max_length = 100
    rand = (from, to) -> from + Math.floor(Math.random() * (to - from))
    letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    random_array = (length) ->
      for i in [0...rand(1, length)]
        letters[rand(0, letters.length)]

    for length in [1...max_length]
      for i in [0...iterations]
        origin = random_array(length)
        target = random_array(length)

        operations = Transform(origin, target)
        expect(replay(origin, operations)).to.eql(target)
