(function() {
  var Monkey;

  Monkey = {
    VERSION: '0.1.0',
    _views: [],
    render: function(name, model, controller) {
      return this._views[name].compile(this.document, model, controller);
    },
    registerView: function(name, template) {
      return this._views[name] = new Monkey.View(template);
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
    document: typeof window !== "undefined" && window !== null ? window.document : void 0
  };

  exports.Monkey = Monkey;

}).call(this);
