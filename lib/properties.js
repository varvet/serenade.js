(function() {
  var Monkey;

  Monkey = require('./monkey').Monkey;

  Monkey.Properties = {
    property: function(name, options) {
      this.properties || (this.properties = {});
      this.properties[name] = options;
      return Object.defineProperty(this, name, {
        get: function() {
          return Monkey.Properties.get.call(this, name);
        },
        set: function(value) {
          return Monkey.Properties.set.call(this, name, value);
        }
      });
    },
    collection: function(name, options) {
      return this.property(name, {
        get: function() {
          var _base;
          return (_base = this.attributes)[name] || (_base[name] = new Monkey.Collection([]));
        },
        set: function(value) {
          return this.get(name).update(value);
        }
      });
    },
    set: function(property, value) {
      var _ref, _ref2;
      this.attributes || (this.attributes = {});
      if ((_ref = this.properties) != null ? (_ref2 = _ref[property]) != null ? _ref2.set : void 0 : void 0) {
        this.properties[property].set.call(this, value);
      } else {
        this.attributes[property] = value;
      }
      if (typeof this.trigger === "function") {
        this.trigger("change:" + property, value);
      }
      return typeof this.trigger === "function" ? this.trigger("change", property, value) : void 0;
    },
    get: function(property) {
      var _ref, _ref2;
      this.attributes || (this.attributes = {});
      if ((_ref = this.properties) != null ? (_ref2 = _ref[property]) != null ? _ref2.get : void 0 : void 0) {
        return this.properties[property].get.call(this);
      } else {
        return this.attributes[property];
      }
    }
  };

}).call(this);
