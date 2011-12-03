
  Monkey.Model = (function() {

    function Model() {}

    Monkey.extend(Model.prototype, Events);

    Model.property = function(name) {
      return Object.defineProperty(this.prototype, name, {
        get: function() {
          return Monkey.Model.get.call(this, name);
        },
        set: function(value) {
          return Monkey.Model.set.call(this, name, value);
        }
      });
    };

    Model.set = function(property, value) {
      this._properties || (this._properties = {});
      this._properties[name] = value;
      return this.trigger("change:" + property, value);
    };

    Model.get = function(property) {
      this._properties || (this._properties = {});
      return this._properties[name];
    };

    Model.prototype.get = Model.get;

    Model.prototype.set = Model.set;

    return Model;

  })();
