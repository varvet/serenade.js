Model.belongsTo = (name, options={}) ->
  propOptions = merge options,
    set: (model) ->
      valueName = "_" + name
      if model and model.constructor is Object and options.as
        model = new (options.as())(model)
      previous = @[valueName]
      @[valueName] = model

      if options.inverseOf
        newCollection = model?[options.inverseOf] or new Collection()
        oldCollection = previous?[options.inverseOf] or new Collection()

        oldCollection.delete(this)
        newCollection.push(this) unless this in newCollection

  @property name, propOptions
  @property name + 'Id',
    get: -> @[name]?.id
    set: (id) -> @[name] = options.as().find(id) if id?
    dependsOn: name
    serialize: options.serializeId
