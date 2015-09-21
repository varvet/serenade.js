"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(object, property, receiver) { var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

var _inherits = function (subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; };

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _View2 = require("./view");

var _View3 = _interopRequireDefault(_View2);

var _Collection = require("../collection");

var _Collection2 = _interopRequireDefault(_Collection);

var _settings = require("../helpers");

var DynamicView = (function (_View) {
  function DynamicView(ast, context) {
    _classCallCheck(this, DynamicView);

    _get(Object.getPrototypeOf(DynamicView.prototype), "constructor", this).call(this);
    this.ast = ast;
    this.context = context;
    this.anchor = _settings.settings.document.createTextNode("");
    this.items = [];
    this.children = new _Collection2["default"]();
  }

  _inherits(DynamicView, _View);

  _createClass(DynamicView, [{
    key: "replace",
    value: function replace(children) {
      this.clear();
      this.children = new _Collection2["default"](children);
      this.rebuild();
    }
  }, {
    key: "rebuild",
    value: function rebuild() {
      var _this = this;

      if (this.anchor.parentNode) {
        (function () {
          var last = _this.anchor;
          _this.children.forEach(function (child) {
            child.insertAfter(last);
            last = child.lastElement;
          });
        })();
      }
    }
  }, {
    key: "clear",
    value: function clear() {
      this.children.forEach(function (child) {
        return child.remove();
      });
      this.children.update([]);
    }
  }, {
    key: "remove",
    value: function remove() {
      this.detach();
      this.clear();
      if (this.anchor.parentNode) {
        this.anchor.parentNode.removeChild(this.anchor);
      }
    }
  }, {
    key: "append",
    value: function append(inside) {
      inside.appendChild(this.anchor);
      this.rebuild();
    }
  }, {
    key: "insertAfter",
    value: function insertAfter(after) {
      after.parentNode.insertBefore(this.anchor, after.nextSibling);
      this.rebuild();
    }
  }, {
    key: "lastElement",
    get: function () {
      return this.children.last && this.children.last.lastElement || this.anchor;
    }
  }]);

  return DynamicView;
})(_View3["default"]);

exports["default"] = DynamicView;
module.exports = exports["default"];
