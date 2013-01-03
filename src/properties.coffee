{defineProperty} = require("./property")

Properties =
  property: (name, options={}) ->
    defineProperty(this, name, options)

exports.Properties = Properties
