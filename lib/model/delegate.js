"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _helpers = require("../helpers");

exports["default"] = function () {
  var _this = this;

  for (var _len = arguments.length, names = Array(_len), _key = 0; _key < _len; _key++) {
    names[_key] = arguments[_key];
  }

  var options = typeof names[names.length - 1] !== "string" ? names.pop() : {};
  var to = options.to;

  names.forEach(function (name) {
    var propName = name;
    if (options.prefix === true) {
      propName = to + (0, _helpers.capitalize)(propName);
    } else if (options.prefix) {
      propName = options.prefix + (0, _helpers.capitalize)(propName);
    }
    if (options.suffix === true) {
      propName = propName + (0, _helpers.capitalize)(to);
    } else if (options.suffix) {
      propName = propName + options.suffix;
    }
    var propOptions = (0, _helpers.merge)(options, {
      dependsOn: options.dependsOn || to + "." + name,
      get: function get() {
        return this[to] && this[to][name];
      },
      set: function set(value) {
        if (this[to]) {
          this[to][name] = value;
        }
      },
      format: function format() {
        if (this[to]) {
          return (0, _helpers.format)(this[to], name);
        }
      }
    });

    _this.property(propName, propOptions);
  });
};

;
module.exports = exports["default"];
