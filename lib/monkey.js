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
    document: typeof window !== "undefined" && window !== null ? window.document : void 0,
    Events: require('./events').Events,
    Collection: require('./collection').Collection
  };

  exports.Monkey = Monkey;

}).call(this);
