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

var _settings = require("../helpers");

var _Compile = require("../compile");

var _Compile2 = _interopRequireDefault(_Compile);

var _Collection = require("../collection");

var _Collection2 = _interopRequireDefault(_Collection);

var TemplateView = (function (_DynamicView) {
  function TemplateView(asts, context) {
    _classCallCheck(this, TemplateView);

    _get(Object.getPrototypeOf(TemplateView.prototype), "constructor", this).call(this, asts, context);
    this.children = new _Collection2["default"](asts.map(function (ast) {
      return _Compile2["default"][ast.type](ast, context);
    }));
  }

  _inherits(TemplateView, _DynamicView);

  _createClass(TemplateView, [{
    key: "fragment",
    get: function () {
      var _this = this;

      var fragment = _settings.settings.document.createDocumentFragment();
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
})(_DynamicView3["default"]);

exports["default"] = TemplateView;
module.exports = exports["default"];
