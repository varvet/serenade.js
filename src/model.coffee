{Monkey} = require './monkey'

class Monkey.Model
  Monkey.extend(@prototype, Monkey.Events)
  Monkey.extend(@prototype, Monkey.Properties)

  @property: -> @prototype.property(arguments...)
  @collection: -> @prototype.collection(arguments...)

  constructor: (attributes) ->
    @set(attributes)
