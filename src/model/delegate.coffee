Model.delegate = (names..., options) ->
  to = options.to
  names.forEach (name) =>
    propName = name
    if options.prefix is true
      propName = to + capitalize(name)
    else if options.prefix
      propName = options.prefix + capitalize(name)
    if options.suffix is true
      propName = propName + capitalize(to)
    else if options.suffix
      propName = propName + options.suffix
    propOptions = merge options,
      dependsOn: options.dependsOn or "#{to}.#{name}"
      get: -> @[to]?[name]
      set: (value) -> @[to]?[name] = value
    @property propName, propOptions
