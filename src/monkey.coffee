Monkey =
  VERSION: '0.1.0'
  _views: []
  _controllers: []

  registerView: (name, template) ->
    @_views[name] = new Monkey.View(template)
  render: (name, model, controller) ->
    controller or= @controllerFor(name)
    @_views[name].render(@document, model, controller)

  registerController: (name, klass) ->
    @_controllers[name] = klass
  controllerFor: (name) ->
    if @_controllers[name]
      new (@_controllers[name])()
    else
      {}

  extend: (target, source) ->
    for key, value of source
      if Object.prototype.hasOwnProperty.call(source, key)
        target[key] = value
  document: window?.document
  get: (model, value, bound=true) ->
    if bound and model.get
      model.get(value)
    else if bound
      model[value]
    else
      value
  # Iteration with fallback
  forEach: (collection, fun) ->
    if typeof(collection.forEach) is 'function'
      collection.forEach(fun)
    else
      fun(element) for element in collection

exports.Monkey = Monkey
