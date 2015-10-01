"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(_x3, _x4, _x5) { var _again = true; _function: while (_again) { var object = _x3, property = _x4, receiver = _x5; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x3 = parent; _x4 = property; _x5 = receiver; _again = true; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var _view = require("./view");

var _view2 = _interopRequireDefault(_view);

var _collection = require("../collection");

var _collection2 = _interopRequireDefault(_collection);

var _helpers = require("../helpers");

var DynamicView = (function (_View) {
  _inherits(DynamicView, _View);

  function DynamicView(ast, context) {
    _classCallCheck(this, DynamicView);

    _get(Object.getPrototypeOf(DynamicView.prototype), "constructor", this).call(this);
    this.ast = ast;
    this.context = context;
    this.anchor = _helpers.settings.document.createTextNode('');
    this.items = [];
    this.children = new _collection2["default"]();
  }

  _createClass(DynamicView, [{
    key: "replace",
    value: function replace(children) {
      this.clear();
      this.children = new _collection2["default"](children);
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
            child.insertAfter(last, !_this.attached);
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
      this.children.forEach(function (child) {
        return child.remove();
      });
      if (this.anchor.parentNode) {
        this.anchor.parentNode.removeChild(this.anchor);
      }
    }
  }, {
    key: "append",
    value: function append(inside) {
      var skipAttach = arguments.length <= 1 || arguments[1] === undefined ? false : arguments[1];

      inside.appendChild(this.anchor);
      this.rebuild();
      if (!skipAttach) this.attach();
    }
  }, {
    key: "insertAfter",
    value: function insertAfter(after) {
      var skipAttach = arguments.length <= 1 || arguments[1] === undefined ? false : arguments[1];

      after.parentNode.insertBefore(this.anchor, after.nextSibling);
      this.rebuild();
      if (!skipAttach) this.attach();
    }
  }, {
    key: "lastElement",
    get: function get() {
      return this.children.last && this.children.last.lastElement || this.anchor;
    }
  }]);

  return DynamicView;
})(_view2["default"]);

exports["default"] = DynamicView;
module.exports = exports["default"];
