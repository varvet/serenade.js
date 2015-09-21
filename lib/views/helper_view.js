"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _toConsumableArray = function (arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i]; return arr2; } else { return Array.from(arr); } };

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

function normalize(val) {
  if (!val) {
    return [];
  }return new _Collection2["default"]([].concat(val).reduce(function (aggregate, element) {
    if (typeof element === "string") {
      var div = _settings.settings.document.createElement("div");
      div.innerHTML = element;
      Array.prototype.forEach.call(div.childNodes, function (child) {
        aggregate.push(new _View2["default"](child));
      });
    } else if (element && element.isView) {
      aggregate = aggregate.concat(element);
    } else {
      aggregate.push(new _View2["default"](element));
    }
    return aggregate;
  }, []));
};

var HelperView = (function (_DynamicView) {
  function HelperView(ast, context, helper) {
    var _this = this;

    _classCallCheck(this, HelperView);

    _get(Object.getPrototypeOf(HelperView.prototype), "constructor", this).call(this, ast, context);

    this.helper = helper;
    this.render = this.render.bind(this);
    this.update = this.update.bind(this);

    this.update();

    this.ast.arguments.forEach(function (_ref) {
      var value = _ref.value;
      var bound = _ref.bound;

      if (bound === true) {
        _this._bindEvent(context["" + value + "_property"], _this.update);
      }
    });
  }

  _inherits(HelperView, _DynamicView);

  _createClass(HelperView, [{
    key: "update",
    value: function update() {
      var _helper;

      this.clear();
      this.children = normalize((_helper = this.helper).call.apply(_helper, [{
        context: this.context,
        render: this.render
      }].concat(_toConsumableArray(this.arguments))));
      this.rebuild();
    }
  }, {
    key: "arguments",
    get: function () {
      var _this2 = this;

      return this.ast.arguments.map(function (argument) {
        return argument["static"] || argument.bound ? _this2.context[argument.value] : argument.value;
      });
    }
  }, {
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
