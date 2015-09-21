"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _get = function get(object, property, receiver) { var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

var _inherits = function (subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; };

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _DynamicView2 = require("./dynamic_view");

var _DynamicView3 = _interopRequireDefault(_DynamicView2);

var _TemplateView = require("./template_view");

var _TemplateView2 = _interopRequireDefault(_TemplateView);

var _Compile = require("../compile");

var _Compile2 = _interopRequireDefault(_Compile);

var UnlessView = (function (_DynamicView) {
  function UnlessView(ast, context) {
    var _this = this;

    _classCallCheck(this, UnlessView);

    _get(Object.getPrototypeOf(UnlessView.prototype), "constructor", this).call(this, ast, context);
    this._bindToModel(ast.argument, function (value) {
      if (value) {
        return _this.clear();
      } else {
        return _this.replace([new _TemplateView2["default"](ast.children, context)]);
      }
    });
  }

  _inherits(UnlessView, _DynamicView);

  return UnlessView;
})(_DynamicView3["default"]);

_Compile2["default"].unless = function (ast, context) {
  return new UnlessView(ast, context);
};

exports["default"] = UnlessView;
module.exports = exports["default"];
