(function() {
  var Events, Serenade, extend;

  Serenade = require('./serenade').Serenade;

  Events = require('./events').Events;

  extend = require('./helpers').extend;

  Serenade.Model = (function() {

    extend(Model.prototype, Events);

    extend(Model.prototype, Serenade.Properties);

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
      var document, _ref, _ref2, _ref3, _ref4, _ref5, _ref6;
      if (document = this._getFromCache(id)) {
        if ((_ref = (_ref2 = this._storeOptions) != null ? _ref2.refresh : void 0) === 'always') {
          document.refresh();
        }
        if (((_ref3 = (_ref4 = this._storeOptions) != null ? _ref4.refresh : void 0) === 'stale') && document.isStale()) {
          document.refresh();
        }
      } else {
        document = new this({
          id: id
        });
        if ((_ref5 = (_ref6 = this._storeOptions) != null ? _ref6.refresh : void 0) === 'always' || _ref5 === 'stale' || _ref5 === 'new') {
          document.refresh();
        }
      }
      return document;
    };

    Model.store = function(options) {
      return this._storeOptions = options;
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

    Model.prototype.refresh = function() {};

    Model.prototype.save = function() {};

    Model.prototype.isStale = function() {
      return this.get('expires') < new Date();
    };

    return Model;

  })();

}).call(this);
