Monkey =
  render: -> Monkey.Renderer.render(arguments...)
  registerView: (name, fun) -> Monkey.Renderer._views[name] = fun
  extend: (target, source) ->
    for key, value of source
      if Object.prototype.hasOwnProperty.call(source, key)
        target[key] = value

exports.Monkey = Monkey

Monkey.Parser = require('./grammar').Parser
require('./nodes')
require('./lexer')
require('./properties')
require('./events')
require('./model')
require('./view')
