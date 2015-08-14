class Person
  @attribute "firstName"
  @attribute "lastName"

  @property "name", (firstName, lastName) ->
    [firstName, lastName].join(" ")
