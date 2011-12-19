(function() {
  var Monkey;

  Monkey = require('./monkey').Monkey;

  Monkey.Model = (function() {

    Monkey.extend(Model.prototype, Monkey.Events);

    Monkey.extend(Model.prototype, Monkey.Properties);

    Model.property = function() {
      var _ref;
      return (_ref = this.prototype).property.apply(_ref, arguments);
    };

    Model.collection = function() {
      var _ref;
      return (_ref = this.prototype).collection.apply(_ref, arguments);
    };

    function Model(attributes) {
      this.set(attributes);
    }

    return Model;

  })();

}).call(this);
