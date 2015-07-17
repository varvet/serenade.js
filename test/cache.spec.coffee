require './spec_helper'
Serenade = require('../lib/serenade')
{Cache} = Serenade

describe 'Serenade.Cache', ->
  beforeEach ->
    class CTOR extends Serenade.Model
      constructor: (@attributes) ->
    @ctor = CTOR
    @uid = @ctor.uniqueId()

  describe '.get', ->
    it 'returns undefined when nothing has been cached', ->
      expect(Cache.get(@ctor, 4)).to.not.exist
    it 'retrieves an object from the identity map', ->
      obj = {}
      Cache.set(@ctor, 4, obj)
      expect(Cache.get(@ctor, 4)).to.eql(obj)
