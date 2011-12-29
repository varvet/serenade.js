(function() {
  var Monkey;

  Monkey = {
    VERSION: '0.1.0',
    _views: {},
    _controllers: {},
    _formats: {},
    registerView: function(name, template) {
      var View;
      View = require('./view').View;
      return this._views[name] = new View(template);
    },
    render: function(name, model, controller) {
      controller || (controller = this.controllerFor(name));
      return this._views[name].render(this.document, model, controller);
    },
    registerController: function(name, klass) {
      return this._controllers[name] = klass;
    },
    controllerFor: function(name) {
      if (this._controllers[name]) {
        return new this._controllers[name]();
      } else {
        return {};
      }
    },
    registerFormat: function(name, fun) {
      return this._formats[name] = fun;
    },
    extend: function(target, source) {
      var key, value, _results;
      _results = [];
      for (key in source) {
        value = source[key];
        if (Object.prototype.hasOwnProperty.call(source, key)) {
          _results.push(target[key] = value);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    document: typeof window !== "undefined" && window !== null ? window.document : void 0,
    get: function(model, value, bound) {
      if (bound == null) bound = true;
      if (bound && model.get) {
        return model.get(value);
      } else if (bound) {
        return model[value];
      } else {
        return value;
      }
    },
    format: function(model, value, bound) {
      if (bound == null) bound = true;
      if (bound && model.format) {
        return model.format(value);
      } else {
        return this.get(model, value, bound);
      }
    },
    forEach: function(collection, fun) {
      var element, _i, _len, _results;
      if (typeof collection.forEach === 'function') {
        return collection.forEach(fun);
      } else {
        _results = [];
        for (_i = 0, _len = collection.length; _i < _len; _i++) {
          element = collection[_i];
          _results.push(fun(element));
        }
        return _results;
      }
    }
  };

  exports.Monkey = Monkey;

}).call(this);
