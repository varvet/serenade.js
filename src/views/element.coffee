class Element extends View
  defineEvent(@prototype, "load", async: false)
  defineEvent(@prototype, "unload", async: false)

  constructor: (@ast, @model, @controller) ->
    super Serenade.document.createElement(@ast.name)

    @node.setAttribute('id', @ast.id) if @ast.id
    @node.setAttribute('class', @ast.classes.join(' ')) if @ast.classes?.length

    for child in @ast.children
      childView = Compile[child.type](child, @model, @controller)
      childView.append(@node)
      @children.push(childView)

    @ast.properties.forEach (property) =>
      action = if property.scope is "attribute" and property.name is "binding"
        @property.binding
      else
        @property[property.scope]

      if action
        action.setup.call(this, property) if action.setup

        if action.update
          if property.static
            action.update.call(this, property, @model[property.value])
          else if property.bound
            if property.value
              @_bindToModel property.value, (value) =>
                action.update.call(this, property, value)
            else
              action.update.call(this, property, @model)
          else
            action.update.call(this, property, property.value)
        else if property.bound
          throw SyntaxError "properties in scope #{property.scope} cannot be bound, use: `#{property.scope}:#{property.name}=#{property.value}`"

      else
        throw SyntaxError "#{property.scope} is not a valid scope"
    @load.trigger()

  _updateClass: ->
    classes = @ast.classes
    classes = classes.concat(@attributeClasses) if @attributeClasses
    classes = classes.concat(@boundClasses.toArray()) if @boundClasses?.length
    classes.sort()
    if classes.length
      assignUnlessEqual(@node, "className", classes.join(' '))
    else
      @node.removeAttribute("class")

  detach: ->
    @unload.trigger()
    super

  property:
    style:
      update: (property, value) ->
        assignUnlessEqual(@node.style, property.name, value)

    event:
      setup: (property) ->
        @node.addEventListener property.name, (e) =>
          e.preventDefault() if property.preventDefault
          @controller[property.value](@node, @model, e)

    class:
      update: (property, value) ->
        if value
          @boundClasses or= new Collection()
          unless @boundClasses?.includes(property.name)
            @boundClasses.push(property.name)
            @_updateClass()
        else if @boundClasses
          index = @boundClasses.indexOf(property.name)
          @boundClasses.delete(property.name)
          @_updateClass()

    binding:
      setup: (property) ->
        @ast.name in ["input", "textarea", "select"] or throw SyntaxError "invalid view type #{@ast.name} for two way binding"
        property.value or throw SyntaxError "cannot bind to whole model, please specify an attribute to bind to"

        domUpdated = =>
          @model[property.value] = if @node.type is "checkbox"
            @node.checked
          else if @node.type is "radio"
            @node.getAttribute("value") if @node.checked
          else
            @node.value

        if property.name is "binding"
          # we can't bind to the form directly since it doesn't exist yet
          handler = (e) => domUpdated() if @node.form is (e.target or e.srcElement)
          Serenade.document.addEventListener("submit", handler, true)
          @unload.bind -> Serenade.document.removeEventListener("submit", handler, true)
        else
          @node.addEventListener(property.name, domUpdated)

      update: (property, value) ->
        if @node.type is "checkbox"
          @node.checked = !!value
        else if @node.type is "radio"
          @node.checked = true if value is @node.getAttribute("value")
        else
          value = "" if value == undefined
          assignUnlessEqual(@node, "value", value)

    attribute:
      update: (property, value) ->
        if property.name is 'value'
          assignUnlessEqual(@node, "value", value or '')
        else if @ast.name is 'input' and property.name is 'checked'
          assignUnlessEqual(@node, "checked", !!value)
        else if property.name is 'class'
          @attributeClasses = value
          @_updateClass()
        else if value is undefined
          @node.removeAttribute(property.name) if @node.hasAttribute(property.name)
        else
          value = "0" if value is 0
          unless @node.getAttribute(property.name) is value
            @node.setAttribute(property.name, value)

    on:
      setup: (property) ->
        if property.name in ["load", "unload"]
          @[property.name].bind ->
            @controller[property.value](@node, @model)
        else
          throw new SyntaxError("unkown lifecycle event '#{property.name}'")

    property:
      update: (property, value) ->
        assignUnlessEqual(@node, property.name, value)

