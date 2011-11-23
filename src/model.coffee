class Monkey.Model
  Monkey.extend(@prototype, Monkey.Events)
  Monkey.extend(@prototype, Monkey.Properties)

  @property: -> @prototype.property(arguments...)
