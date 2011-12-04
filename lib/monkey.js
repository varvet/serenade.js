(function() {
  var Monkey;
  Monkey = {
    render: function() {
      var _ref;
      return (_ref = Monkey.Renderer).render.apply(_ref, arguments);
    },
    registerView: function(name, fun) {
      return Monkey.Renderer._views[name] = fun;
    },
    extend: function(target, source) {
      var key, value, _results;
      _results = [];
      for (key in source) {
        value = source[key];
        _results.push(Object.prototype.hasOwnProperty.call(source, key) ? target[key] = value : void 0);
      }
      return _results;
    }
  };
  window.Monkey = Monkey;
}).call(this);
