"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var _dynamic_view = require("./dynamic_view");

var _dynamic_view2 = _interopRequireDefault(_dynamic_view);

var _view = require("./view");

var _view2 = _interopRequireDefault(_view);

var _template_view = require("./template_view");

var _template_view2 = _interopRequireDefault(_template_view);

var _collection = require("../collection");

var _collection2 = _interopRequireDefault(_collection);

var _helpers = require("../helpers");

var _compile = require("../compile");

var _compile2 = _interopRequireDefault(_compile);

var _channel = require("../channel");

var _channel2 = _interopRequireDefault(_channel);

function normalize(val) {
  if (!val) {
    return [];
  } else if (val.isView) {
    return [val];
  } else {
    return [new _view2["default"](val)];
  }
};

var HelperView = (function (_DynamicView) {
  _inherits(HelperView, _DynamicView);

  function HelperView(ast, context, helper) {
    var _this = this;

    _classCallCheck(this, HelperView);

    _get(Object.getPrototypeOf(HelperView.prototype), "constructor", this).call(this);
    this.ast = ast;
    this.context = context;

    this.helper = helper;

    var argChannels = this.ast.arguments.map(function (property) {
      return _compile2["default"].parameter(property, context);
    });
    this.bind(_channel2["default"].all(argChannels), function (args) {
      var result = _this.helper.apply({
        context: _this.context,
        render: _this.render.bind(_this)
      }, args);
      _this.replace(normalize(result));
    });
  }

  _createClass(HelperView, [{
    key: "render",
    value: function render(context) {
      return new _template_view2["default"](this.ast.children, context).fragment;
    }
  }]);

  return HelperView;
})(_dynamic_view2["default"]);

_compile2["default"].helper = function (ast, context) {
  return _helpers.settings.views[ast.command](ast, context);
};

exports["default"] = HelperView;
module.exports = exports["default"];
