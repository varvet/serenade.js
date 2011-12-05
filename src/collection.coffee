{Monkey} = require './monkey'

class Monkey.Collection
  Monkey.extend(@prototype, Monkey.Events)
  constructor: (@list) ->
  get: (index) -> @list[index]
  set: (index, value) ->
    @trigger("change:#{index}")
    @trigger("change")
    @list[index] = value
