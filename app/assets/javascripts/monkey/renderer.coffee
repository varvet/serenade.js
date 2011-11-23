class Monkey.Renderer
  @_eventNames: ['click', 'mouseover', 'mouseout', 'change']
  @_views: {}
  @render: (name, model, controller) ->
    renderer = new Monkey.Renderer(model, controller)
    controller.model = model
    controller.view = @_views[name](renderer.builderFunction())

  constructor: (@model, @controller) ->

  convertNode: (node) ->
    if node.hasOwnProperty('bind')
      @boundTextNode(node.bind)
    else if typeof(node) is 'string'
      document.createTextNode(node)
    else
      node

  setAttribute: (element, name, value) ->
    if Monkey.Renderer._eventNames.indexOf(name) >= 0
      element.addEventListener(name, (e) => @controller[value](e))
    else
      if value.hasOwnProperty('bind')
        element.setAttribute(name, @model[value.bind] or '')
        @model.bind "change:#{value.bind}", (newValue) ->
          if name is 'value'
            element.value = newValue or ''
          else
            element.setAttribute(name, newValue or '')
      else
        element.setAttribute(name, value)

  boundTextNode: (name) =>
    node = document.createTextNode(@model[name] or '')
    @model.bind "change:#{name}", (value) ->
      node.textContent = value or ''
    node

  createElement: (tagName, attributes, nodes...) =>
    element = document.createElement(tagName)
    @setAttribute(element, name, value) for name, value of attributes
    element.appendChild(@convertNode(node)) for node in nodes
    element

  builderFunction: ->
    fun = @createElement
    fun.text = @createTextNode
    fun.attr = @createAttribute
    fun
