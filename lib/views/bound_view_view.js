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

var _Compile = require("../compile");

var _Compile2 = _interopRequireDefault(_Compile);

var _settings = require("../helpers");

var BoundViewView = (function (_DynamicView) {
  function BoundViewView(ast, context) {
    var _this = this;

    _classCallCheck(this, BoundViewView);

    _get(Object.getPrototypeOf(BoundViewView.prototype), "constructor", this).call(this, ast, context);

    this._bind(_Compile2["default"].parameter(ast.arguments[0], context), function (value) {
      var view = _settings.settings.templates[value].render(context).view;
      _this.replace([view]);
    });
  }

  _inherits(BoundViewView, _DynamicView);

  return BoundViewView;
})(_DynamicView3["default"]);

_Compile2["default"].view = function (ast, context) {
  if (ast.arguments.length !== 1) {
    throw new Error("`if` must take exactly one argument");
  }

  if (ast.arguments[0].bound) {
    return new BoundViewView(ast, context);
  } else {
    return _settings.settings.templates[ast.arguments[0].value].render(context).view;
  }
};

exports["default"] = BoundViewView;
module.exports = exports["default"];