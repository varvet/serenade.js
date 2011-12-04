Monkey =
  VERSION: '0.1.0'
  _views: []
  render: (name, model, controller) -> @_views[name].compile(@document, model, controller)
  registerView: (name, template) -> @_views[name] = new Monkey.View(template)
  extend: (target, source) ->
    for key, value of source
      if Object.prototype.hasOwnProperty.call(source, key)
        target[key] = value
  document: window?.document

exports.Monkey = Monkey
