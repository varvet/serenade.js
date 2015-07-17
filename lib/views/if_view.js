"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; }

var _dynamic_view = require("./dynamic_view");

var _dynamic_view2 = _interopRequireDefault(_dynamic_view);

var _template_view = require("./template_view");

var _template_view2 = _interopRequireDefault(_template_view);

var _compile = require("../compile");

var _compile2 = _interopRequireDefault(_compile);

var IfView = (function (_DynamicView) {
  _inherits(IfView, _DynamicView);

  function IfView(ast, context) {
    var _this = this;

    _classCallCheck(this, IfView);

    _get(Object.getPrototypeOf(IfView.prototype), "constructor", this).call(this, ast, context);
    this._bindToModel(ast.argument, function (value) {
      if (value) {
        _this.replace([new _template_view2["default"](ast.children, context)]);
      } else if (ast["else"]) {
        _this.replace([new _template_view2["default"](ast["else"].children, context)]);
      } else {
        _this.clear();
      }
    });
  }

  return IfView;
})(_dynamic_view2["default"]);

_compile2["default"]["if"] = function (ast, context) {
  return new IfView(ast, context);
};

exports["default"] = IfView;
module.exports = exports["default"];
