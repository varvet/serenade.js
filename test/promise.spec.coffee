require './spec_helper'
{Promise} = Serenade

adapter =
  fulfilled: (value) ->
    promise = new Promise
    promise.fulfill(value)
    promise
  rejected: (reason) ->
    promise = new Promise
    promise.reject(reason)
    promise
  pending: ->
    promise = new Promise
    fulfill = (value) -> promise.fulfill(value)
    reject = (reason) -> promise.reject(reason)
    {promise, fulfill, reject}

describe "Serenade.Promise", ->
  require("promises-aplus-tests").mocha(adapter)
