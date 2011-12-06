{Monkey} = require './monkey'

class Monkey.Collection
  collection: true
  Monkey.extend(@prototype, Monkey.Events)
  constructor: (@list) ->
  get: (index) -> @list[index]
  set: (index, value) ->
    @trigger("change:#{index}")
    @trigger("change")
    @list[index] = value
  push: (element) ->
    @list.push(element)
  update: (list) ->
    @list = list
  forEach: (fun) ->
    Monkey.each(@list, fun)
