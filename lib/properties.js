(function() {
  Monkey.Properties = {
    property: function(name) {
      return Object.defineProperty(this, name, {
        get: function() {
          return Monkey.Properties.get.call(this, name);
        },
        set: function(value) {
          return Monkey.Properties.set.call(this, name, value);
        }
      });
    },
    set: function(property, value) {
      this.properties || (this.properties = {});
      this.properties[name] = value;
      this.trigger("change:" + property, value);
      return this.trigger("change", property, value);
    },
    get: function(property) {
      this.properties || (this.properties = {});
      return this.properties[name];
    }
  };
}).call(this);
