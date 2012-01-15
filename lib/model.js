(function() {
  var Events, Serenade, extend, get, _ref;

  Serenade = require('./serenade').Serenade;

  Events = require('./events').Events;

  _ref = require('./helpers'), extend = _ref.extend, get = _ref.get;

  Serenade.Model = (function() {

    extend(Model.prototype, Events);

    extend(Model.prototype, Serenade.Properties);

    Model.property = function() {
      var _ref2;
      return (_ref2 = this.prototype).property.apply(_ref2, arguments);
    };

    Model.collection = function() {
      var _ref2;
      return (_ref2 = this.prototype).collection.apply(_ref2, arguments);
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
      var document;
      if (!(document = this._getFromCache(id))) {
        document = new this({
          id: id
        });
      }
      return document;
    };

    Model.belongsTo = function(name, ctor) {
      if (ctor == null) ctor = Object;
      this.property(name, {
        set: function(properties) {
          return this.attributes[name] = new ctor(properties);
        }
      });
      return this.property(name + 'Id', {
        get: function() {
          return get(this.get(name), 'id');
        },
        set: function(id) {
          return this.set(name, ctor.find(id));
        },
        dependsOn: name
      });
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
