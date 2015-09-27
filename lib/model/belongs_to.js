"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _helpers = require("../helpers");

var _collection = require("../collection");

var _collection2 = _interopRequireDefault(_collection);

exports["default"] = function (name) {
  var options = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];

  options = (0, _helpers.merge)({ channelName: "@" + name }, options);

  var attributeOptions = (0, _helpers.merge)(options, {
    set: function set(model) {
      var _this = this;

      if (model && model.constructor === Object && options.as) {
        model = new (options.as())(model);
      }
      this[options.channelName].emit(model);
      if (options.inverseOf && model) {
        (function () {
          var collection = model[options.inverseOf];
          (0, _helpers.addItem)(collection, _this);
          _this[options.channelName].gc(function () {
            return (0, _helpers.deleteItem)(collection, _this);
          });
        })();
      }
    }
  });

  delete attributeOptions.as;

  this.attribute(name, attributeOptions);
  this.property(name + 'Id', {
    get: function get(object) {
      return object && object.id;
    },
    set: function set(id) {
      if (id) {
        this[name] = options.as().find(id);
      }
    },
    dependsOn: name,
    serialize: options.serializeId
  });
};

;
module.exports = exports["default"];
