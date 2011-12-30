(function() {
  var Serenade;

  Serenade = {
    VERSION: '0.1.0',
    _views: {},
    _controllers: {},
    _formats: {},
    registerView: function(name, template) {
      var View;
      View = require('./view').View;
      return this._views[name] = new View(template);
    },
    render: function(name, model, controller, document) {
      if (document == null) {
        document = typeof window !== "undefined" && window !== null ? window.document : void 0;
      }
      controller || (controller = this.controllerFor(name));
      return this._views[name].render(document, model, controller);
    },
    registerController: function(name, klass) {
      return this._controllers[name] = klass;
    },
    controllerFor: function(name) {
      if (this._controllers[name]) return new this._controllers[name]();
    },
    registerFormat: function(name, fun) {
      return this._formats[name] = fun;
    },
    Events: require('./events').Events,
    Collection: require('./collection').Collection
  };

  exports.Serenade = Serenade;

  exports.compile = function() {
    var document, fs, window;
    document = require("jsdom").jsdom(null, null, {});
    fs = require("fs");
    window = document.createWindow();
    return function(env) {
      var element, model, viewName;
      model = env.model;
      viewName = env.filename.split('/').reverse()[0].replace(/\.serenade$/, '');
      Serenade.registerView(viewName, fs.readFileSync(env.filename).toString());
      element = Serenade.render(viewName, model, {}, document);
      document.body.appendChild(element);
      return document.body.innerHTML;
    };
  };

}).call(this);
