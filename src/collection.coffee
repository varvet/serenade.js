{Monkey} = require './monkey'

class Monkey.Collection
  collection: true
  Monkey.extend(@prototype, Monkey.Events)
  constructor: (@list) ->
    @length = @list.length
    @bind("change", => @length = @list.length)
  get: (index) -> @list[index]
  set: (index, value) ->
    @list[index] = value
    @trigger("change:#{index}", value)
    @trigger("set", index, value)
    @trigger("change", @list)
  push: (element) ->
    @list.push(element)
    @trigger("add", element)
    @trigger("change", @list)
  update: (list) ->
    @list = list
    @trigger("update", list)
    @trigger("change", @list)
  forEach: (fun) ->
    Monkey.each(@list, fun)
