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

var _text_view = require("./text_view");

var _text_view2 = _interopRequireDefault(_text_view);

var _compile = require("../compile");

var _compile2 = _interopRequireDefault(_compile);

var _helpers = require("../helpers");

var ContentView = (function (_DynamicView) {
  _inherits(ContentView, _DynamicView);

  function ContentView() {
    _classCallCheck(this, ContentView);

    _get(Object.getPrototypeOf(ContentView.prototype), "constructor", this).apply(this, arguments);
  }

  _createClass(ContentView, [{
    key: "attach",
    value: function attach() {
      var _this = this;

      if (!this.attached) {
        var value = undefined;
        if (this.ast.bound && this.ast.value) {
          value = (0, _helpers.format)(this.context, this.ast.value);
          var property = this.context[this.ast.value + "_property"];
          if (property && property.registerGlobal) {
            property.registerGlobal(value);
          }
          this._bindEvent(property, function (_, value) {
            return _this.update((0, _helpers.format)(_this.context, _this.ast.value, value));
          });
        } else if (this.ast.value) {
          value = this.ast.value;
        } else {
          value = this.context;
        }
        this.update(value);
      }
      _get(Object.getPrototypeOf(ContentView.prototype), "attach", this).call(this);
    }
  }, {
    key: "update",
    value: function update(value) {
      if (value && value.isView) {
        this.replace([value]);
      } else {
        this.replace([new _text_view2["default"](value)]);
      }
    }
  }]);

  return ContentView;
})(_dynamic_view2["default"]);

_compile2["default"].content = function (ast, context) {
  return new ContentView(ast, context);
};

exports["default"] = ContentView;
module.exports = exports["default"];
