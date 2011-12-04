(function() {
  Monkey.Model = (function() {
    function Model() {}
    Monkey.extend(Model.prototype, Monkey.Events);
    Monkey.extend(Model.prototype, Monkey.Properties);
    Model.property = function() {
      var _ref;
      return (_ref = this.prototype).property.apply(_ref, arguments);
    };
    return Model;
  })();
}).call(this);
