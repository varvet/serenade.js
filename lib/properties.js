(function() {
  var Monkey;
  var __hasProp = Object.prototype.hasOwnProperty, __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (__hasProp.call(this, i) && this[i] === item) return i; } return -1; };

  Monkey = require('./monkey').Monkey;

  Monkey.Properties = {
    property: function(name, options) {
      if (options == null) options = {};
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
          var _this = this;
          if (!this.attributes[name]) {
            this.attributes[name] = new Monkey.Collection([]);
            this.attributes[name].bind('change', function() {
              return _this._triggerChangeTo(name, _this.get(name));
            });
          }
          return this.attributes[name];
        },
        set: function(value) {
          return this.get(name).update(value);
        }
      });
    },
    set: function(name, value) {
      var _ref, _ref2;
      this.attributes || (this.attributes = {});
      if ((_ref = this.properties) != null ? (_ref2 = _ref[name]) != null ? _ref2.set : void 0 : void 0) {
        this.properties[name].set.call(this, value);
      } else {
        this.attributes[name] = value;
      }
      return this._triggerChangeTo(name, value);
    },
    get: function(name) {
      var _ref, _ref2;
      this.attributes || (this.attributes = {});
      if ((_ref = this.properties) != null ? (_ref2 = _ref[name]) != null ? _ref2.get : void 0 : void 0) {
        return this.properties[name].get.call(this);
      } else {
        return this.attributes[name];
      }
    },
    _triggerChangeTo: function(name, value) {
      var dependencies, property, propertyName, _ref;
      if (typeof this.trigger === "function") {
        this.trigger("change:" + name, value);
      }
      if (this.properties) {
        _ref = this.properties;
        for (propertyName in _ref) {
          property = _ref[propertyName];
          if (property.dependsOn) {
            dependencies = typeof property.dependsOn === 'string' ? [property.dependsOn] : property.dependsOn;
            if (__indexOf.call(dependencies, name) >= 0) {
              if (typeof this.trigger === "function") {
                this.trigger("change:" + propertyName, this.get(propertyName));
              }
            }
          }
        }
      }
      return typeof this.trigger === "function" ? this.trigger("change", name, value) : void 0;
    }
  };

}).call(this);
