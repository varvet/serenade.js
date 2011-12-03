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
        if (Object.prototype.hasOwnProperty.call(source, key)) {
          _results.push(target[key] = value);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    }
  };

  window.Monkey = Monkey;

}).call(this);
