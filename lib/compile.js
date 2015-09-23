"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _channel = require("./channel");

var _channel2 = _interopRequireDefault(_channel);

var Compile = {
  parameter: function parameter(ast, context) {
    if (ast.bound) {
      if (ast.value === "this") {
        return _channel2["default"]["static"](context);
      } else {
        var value = context && context[ast.value];
        if (value && value.isChannel) {
          return value;
        } else {
          return _channel2["default"]["static"](value);
        }
      }
    } else {
      return _channel2["default"]["static"](ast.value);
    }
  }
};

exports["default"] = Compile;
module.exports = exports["default"];
