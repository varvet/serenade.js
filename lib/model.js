(function() {
  var AjaxCollection, Events, Serenade, extend, get, _ref;

  Serenade = require('./serenade').Serenade;

  AjaxCollection = require('./ajax_collection').AjaxCollection;

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
      var document, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
      if (document = this._getFromCache(id)) {
        if ((_ref2 = (_ref3 = this._storeOptions) != null ? _ref3.refresh : void 0) === 'always') {
          document.refresh();
        }
        if (((_ref4 = (_ref5 = this._storeOptions) != null ? _ref5.refresh : void 0) === 'stale') && document.isStale()) {
          document.refresh();
        }
      } else {
        document = new this({
          id: id
        });
        if ((_ref6 = (_ref7 = this._storeOptions) != null ? _ref7.refresh : void 0) === 'always' || _ref6 === 'stale' || _ref6 === 'new') {
          document.refresh();
        }
      }
      return document;
    };

    Model.all = function() {
      var _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
      if (this._all) {
        if ((_ref2 = (_ref3 = this._storeOptions) != null ? _ref3.refresh : void 0) === 'always') {
          this._all.refresh();
        }
        if (((_ref4 = (_ref5 = this._storeOptions) != null ? _ref5.refresh : void 0) === 'stale') && this._all.isStale()) {
          this._all.refresh();
        }
      } else {
        this._all = new AjaxCollection(this, this._storeOptions.url);
        if ((_ref6 = (_ref7 = this._storeOptions) != null ? _ref7.refresh : void 0) === 'always' || _ref6 === 'stale' || _ref6 === 'new') {
          this._all.refresh();
        }
      }
      return this._all;
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
