"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.helper = helper;
exports.attribute = attribute;
exports.property = property;

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _channel = require("./channel");

var _channel2 = _interopRequireDefault(_channel);

var _property = require("./property");

function helper(object, name, descriptor) {
  var fn = descriptor.value;

  descriptor.value = function () {
    var _this = this;

    for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    return _channel2["default"].all(args).map(function (args) {
      return fn.apply(_this, args);
    });
  };

  return descriptor;
}

function attribute() {
  for (var _len2 = arguments.length, names = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
    names[_key2] = arguments[_key2];
  }

  var options = typeof names[names.length - 1] === "string" ? {} : names.pop();
  return function (klass) {
    names.forEach(function (name) {
      (0, _property.defineAttribute)(klass.prototype, name, options);
    });
    return klass;
  };
}

function property() {
  var options = arguments.length <= 0 || arguments[0] === undefined ? {} : arguments[0];

  return function (object, name, descriptor) {
    options.get = descriptor.value;
    options.returnDescriptor = true;
    return (0, _property.defineProperty)(object, name, options, true);
  };
}
