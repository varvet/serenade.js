"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _Channel = require("./channel");

var _Channel2 = _interopRequireDefault(_Channel);

var Compile = {
  parameter: function parameter(ast, context) {
    if (ast.bound) {
      if (ast.value === "this") {
        return _Channel2["default"]["static"](context);
      } else {
        var value = context && context[ast.value];
        if (value && value.isChannel) {
          return value;
        } else {
          return _Channel2["default"]["static"](value);
        }
      }
    } else {
      return _Channel2["default"]["static"](ast.value);
    }
  }
};

exports["default"] = Compile;
module.exports = exports["default"];
