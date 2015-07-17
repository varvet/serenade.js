"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; }

var _dynamic_view = require("./dynamic_view");

var _dynamic_view2 = _interopRequireDefault(_dynamic_view);

var _helpers = require("../helpers");

var _compile = require("../compile");

var _compile2 = _interopRequireDefault(_compile);

var _collection = require("../collection");

var _collection2 = _interopRequireDefault(_collection);

var TemplateView = (function (_DynamicView) {
  _inherits(TemplateView, _DynamicView);

  function TemplateView(asts, context) {
    _classCallCheck(this, TemplateView);

    _get(Object.getPrototypeOf(TemplateView.prototype), "constructor", this).call(this, asts, context);
    this.children = new _collection2["default"](asts.map(function (ast) {
      return _compile2["default"][ast.type](ast, context);
    }));
  }

  _createClass(TemplateView, [{
    key: "fragment",
    get: function get() {
      var _this = this;

      var fragment = _helpers.settings.document.createDocumentFragment();
      this.append(fragment);
      fragment.view = this;
      fragment.isView = true;
      fragment.remove = this.remove.bind(this);
      fragment.append = this.append.bind(this);
      fragment.insertAfter = this.insertAfter.bind(this);
      fragment.detach = this.detach.bind(this);
      Object.defineProperty(fragment, "lastElement", { get: function get() {
          return _this.lastElement;
        } });
      return fragment;
    }
  }]);

  return TemplateView;
})(_dynamic_view2["default"]);

exports["default"] = TemplateView;
module.exports = exports["default"];
