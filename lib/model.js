(function() {
  var Events, Monkey, extend;

  Monkey = require('./monkey').Monkey;

  Events = require('./events').Events;

  extend = require('./helpers').extend;

  Monkey.Model = (function() {

    extend(Model.prototype, Events);

    extend(Model.prototype, Monkey.Properties);

    Model.property = function() {
      var _ref;
      return (_ref = this.prototype).property.apply(_ref, arguments);
    };

    Model.collection = function() {
      var _ref;
      return (_ref = this.prototype).collection.apply(_ref, arguments);
    };

    Model._getFromCache = function(id) {
      this._identityMap || (this._identityMap = {});
      if (this._identityMap.hasOwnProperty(id)) return this._identityMap[id];
    };

    Model._storeInCache = function(id, object) {
      this._identityMap || (this._identityMap = {});
      return this._identityMap[id] = object;
    };

    Model.find = function(id) {
      return this._getFromCache(id);
    };

    function Model(attributes) {
      var fromCache;
      if (attributes != null ? attributes.id : void 0) {
        fromCache = this.constructor._getFromCache(attributes.id);
        if (fromCache) {
          fromCache.set(attributes);
          return fromCache;
        } else {
          this.constructor._storeInCache(attributes.id, this);
        }
      }
      this.set(attributes);
    }

    return Model;

  })();

}).call(this);
