Model.selection = (name, options={}) ->
  throw new Error("must specify `from` option") unless options.from

  propOptions = merge options,
    get: ->
      current = @[options.from]
      for key, value of options when key in ["filter", "map"]
        current = current[key] (item) ->
          if typeof(options[key]) is "string"
            item[options[key]]
          else
            options[key](item)
      current

    dependsOn: [
      "#{options.from}:#{options.filter}"
      "#{options.from}:#{options.map}"
    ]

  @property name, propOptions
  @property name + 'Count',
    get: -> @[name].length
    dependsOn: name
