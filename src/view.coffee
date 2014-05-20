class View
  constructor: (@model, @controller) ->
    @element = Serenade.document.createElement("div")

  # CURRENT API

  addBoundClass: (className) -> notImplemeted()
  removeBoundClass: (className) -> notImplemeted()
  setAttributeClass: (name, value) -> notImplemeted()
  addChildren: (children) -> notImplemeted()
  append: (inside) -> notImplemeted()
  insertAfter: (after) -> notImplemeted()
  remove: -> notImplemeted()

  # FUTURE?

  appendChild: (view) -> notImplemeted()
  insertBefore: (newView, referenceView) -> notImplemeted()
  removeChild: (view) -> notImplemeted()

  # DONE

  setAttribute: (property, value) -> notImplemeted()
  setAttributeNS: (namespace, property, value) -> notImplemeted()
  getAttribute: (property, value) -> notImplemeted()
  getAttributeNS: (namespace, property, value) -> notImplemeted()

  readyCallback: -> # no op
  insertedCallback: -> # no op
  removedCallback: -> # no op
