{Monkey} = require './monkey'

class Monkey.Collection
  collection: true
  Monkey.extend(@prototype, Monkey.Events)
  constructor: (@list) ->
  get: (index) -> @list[index]
  set: (index, value) ->
    @list[index] = value
    @trigger("change:#{index}")
    @trigger("change")
  push: (element) ->
    @list.push(element)
    @trigger("add")
    @trigger("change")
  update: (list) ->
    @list = list
    @trigger("update")
    @trigger("change")
  forEach: (fun) ->
    Monkey.each(@list, fun)
