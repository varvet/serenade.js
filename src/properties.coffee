{Collection} = require './collection'
{Property, defineProperty} = require("./property")
{pairToObject, serializeObject, extend} = require './helpers'

Properties =
  property: (name, options={}) ->
    defineProperty(this, name, options)

  collection: (name, options={}) ->
    extend options,
      get: ->
        valueName = "_s_#{name}_val"
        unless @[valueName]
          @[valueName] = new Collection([])
          @[valueName].bind 'change', =>
            @[name + "_property"].triggerChanges(this)
        @[valueName]
      set: (value) ->
        @[name].update(value)
    @property name, options

exports.Properties = Properties
