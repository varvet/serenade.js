Serenade =
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

exports.Serenade = Serenade

# Express.js support
exports.compile = ->
  Serenade.document = require("jsdom").jsdom(null, null, {})
  fs = require("fs")
  window = Serenade.document.createWindow()

  (env) ->
    model = env.model
    viewName = env.filename.split('/').reverse()[0].replace(/\.serenade$/, '')
    Serenade.registerView(viewName, fs.readFileSync(env.filename).toString())
    element = Serenade.render(viewName, model, {})
    Serenade.document.body.appendChild(element)
    Serenade.document.body.innerHTML
