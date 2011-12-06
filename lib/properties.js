(function() {
  var Monkey;

  Monkey = require('./monkey').Monkey;

  Monkey.Properties = {
    property: function(name, options) {
      this.propertyOptions || (this.propertyOptions = {});
      this.propertyOptions[name] = options;
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
        "default": function() {
          return new Monkey.Collection([]);
        }
      });
    },
    set: function(property, value) {
      this.properties || (this.properties = {});
      this.properties[property] = value;
      this.trigger("change:" + property, value);
      return this.trigger("change", property, value);
    },
    get: function(property) {
      var _ref, _ref2;
      this.properties || (this.properties = {});
      if (!this.properties.hasOwnProperty(property)) {
        this.properties[property] = (_ref = this.propertyOptions) != null ? (_ref2 = _ref[property]) != null ? typeof _ref2['default'] === "function" ? _ref2['default']() : void 0 : void 0 : void 0;
      }
      return this.properties[property];
    }
  };

}).call(this);
