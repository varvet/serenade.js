class DomElement
  constructor: (name) ->
    @element = Serenade.document.createElement(name)

  set: (name, value) ->
    @element.setAttribute(name, value)

  event: (name, fn) ->
    @element.addEventListener(name, fn)
