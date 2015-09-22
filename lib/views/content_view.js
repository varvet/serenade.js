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

var _TextView = require("./text_view");

var _TextView2 = _interopRequireDefault(_TextView);

var _Compile = require("../compile");

var _Compile2 = _interopRequireDefault(_Compile);

var _format = require("../helpers");

var ContentView = (function (_DynamicView) {
  function ContentView(ast, context) {
    var _this = this;

    _classCallCheck(this, ContentView);

    var value = undefined;
    _get(Object.getPrototypeOf(ContentView.prototype), "constructor", this).call(this, ast, context);

    var channel = _Compile2["default"].parameter(ast, context);

    this._bind(channel, function (value) {
      _this.update(value);
    });
  }

  _inherits(ContentView, _DynamicView);

  _createClass(ContentView, [{
    key: "update",
    value: function update(value) {
      if (value && value.isView) {
        this.replace([value]);
      } else {
        this.replace([new _TextView2["default"](value)]);
      }
    }
  }]);

  return ContentView;
})(_DynamicView3["default"]);

_Compile2["default"].content = function (ast, context) {
  return new ContentView(ast, context);
};

exports["default"] = ContentView;
module.exports = exports["default"];
