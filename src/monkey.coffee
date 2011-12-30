Monkey =
  VERSION: '0.1.0'
  _views: {}
  _controllers: {}
  _formats: {}

  registerView: (name, template) ->
    {View} = require('./view')
    @_views[name] = new View(template)
  render: (name, model, controller) ->
    controller or= @controllerFor(name)
    @_views[name].render(@document, model, controller)

  registerController: (name, klass) ->
    @_controllers[name] = klass
  controllerFor: (name) ->
    new (@_controllers[name])() if @_controllers[name]
  registerFormat: (name, fun) ->
    @_formats[name] = fun
  document: window?.document

  Events: require('./events').Events
  Collection: require('./collection').Collection

exports.Monkey = Monkey
