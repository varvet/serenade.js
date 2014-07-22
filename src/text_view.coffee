formatTextValue = (value) ->
  value = "0" if value is 0
  value or ""

class TextView extends View
  constructor: (@ast, @model, @controller) ->
    if ast.bound and ast.value
      value = @model[ast.value]
      property = @model["#{ast.value}_property"]
      property?.registerGlobal?(value)
      @_bindEvent(property, (_, value) => @update(value))
      value
    else if ast.value
      value = ast.value
    else
      value = model

    super Serenade.document.createTextNode("")
    @update(value)

  update: (value) ->
    assignUnlessEqual @node, "nodeValue", formatTextValue(value)
