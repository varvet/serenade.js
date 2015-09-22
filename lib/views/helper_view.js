"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(object, property, receiver) { var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

var _inherits = function (subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; };

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _DynamicView2 = require("./dynamic_view");

var _DynamicView3 = _interopRequireDefault(_DynamicView2);

var _View = require("./view");

var _View2 = _interopRequireDefault(_View);

var _TemplateView = require("./template_view");

var _TemplateView2 = _interopRequireDefault(_TemplateView);

var _Collection = require("../collection");

var _Collection2 = _interopRequireDefault(_Collection);

var _settings = require("../helpers");

var _Compile = require("../compile");

var _Compile2 = _interopRequireDefault(_Compile);

var _Channel = require("../channel");

var _Channel2 = _interopRequireDefault(_Channel);

function normalize(val) {
  if (!val) {
    return [];
  } else if (val.isView) {
    return [val];
  } else {
    return [new _View2["default"](val)];
  }
};

var HelperView = (function (_DynamicView) {
  function HelperView(ast, context, helper) {
    var _this = this;

    _classCallCheck(this, HelperView);

    _get(Object.getPrototypeOf(HelperView.prototype), "constructor", this).call(this, ast, context);

    this.helper = helper;

    var argChannels = this.ast.arguments.map(function (property) {
      return _Compile2["default"].parameter(property, context);
    });
    this._bind(_Channel2["default"].all(argChannels), function (args) {
      var result = _this.helper.apply({
        context: _this.context,
        render: _this.render.bind(_this) }, args);
      _this.replace(normalize(result));
    });
  }

  _inherits(HelperView, _DynamicView);

  _createClass(HelperView, [{
    key: "render",
    value: function render(context) {
      return new _TemplateView2["default"](this.ast.children, context).fragment;
    }
  }]);

  return HelperView;
})(_DynamicView3["default"]);

_Compile2["default"].helper = function (ast, context) {
  return _settings.settings.views[ast.command](ast, context);
};

exports["default"] = HelperView;
module.exports = exports["default"];
