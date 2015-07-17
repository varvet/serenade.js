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

var _template_view = require("./template_view");

var _template_view2 = _interopRequireDefault(_template_view);

var _text_view = require("./text_view");

var _text_view2 = _interopRequireDefault(_text_view);

var _compile = require("../compile");

var _compile2 = _interopRequireDefault(_compile);

var _collection = require("../collection");

var _collection2 = _interopRequireDefault(_collection);

var _transform = require("../transform");

var _transform2 = _interopRequireDefault(_transform);

var CollectionView = (function (_DynamicView) {
  _inherits(CollectionView, _DynamicView);

  function CollectionView(ast, context) {
    var _this = this;

    _classCallCheck(this, CollectionView);

    _get(Object.getPrototypeOf(CollectionView.prototype), "constructor", this).call(this, ast, context);

    this.update = this.update.bind(this);

    var items = this.context[ast.argument] || [];
    this.lastItems = items.map(function (i) {
      return i;
    });
    this.children = new _collection2["default"](items.map(this._toView.bind(this)));
    this.cb = function (_, after) {
      return _this.replace(after);
    };
    this._bindEvent(this.context["" + ast.argument + "_property"], this.update);
    this._bindEvent(items.change, this.cb);
  }

  _createClass(CollectionView, [{
    key: "update",
    value: function update(before, after) {
      this._unbindEvent(before && before.change, this.cb);
      this._bindEvent(after && after.change, this.cb);
      this.replace(after);
    }
  }, {
    key: "replace",
    value: function replace(items) {
      var _this2 = this;

      (0, _transform2["default"])(this.lastItems, items).forEach(function (operation) {
        if (operation.type == "insert") {
          _this2._insertChild(operation.index, _this2._toView(operation.value));
        } else if (operation.type == "remove") {
          _this2._deleteChild(operation.index);
        } else if (operation.type == "swap") {
          _this2._swapChildren(operation.index, operation["with"]);
        }
      });
      if (items) {
        this.lastItems = items.map(function (i) {
          return i;
        });
      } else {
        this.lastItems = [];
      }
    }
  }, {
    key: "_toView",
    value: function _toView(item) {
      if (this.ast.children.length) {
        return new _template_view2["default"](this.ast.children || [], item);
      } else if (item && item.isView) {
        return item;
      } else {
        return new _text_view2["default"](item);
      }
    }
  }, {
    key: "_deleteChild",
    value: function _deleteChild(index) {
      this.children[index].remove();
      this.children.deleteAt(index);
    }
  }, {
    key: "_insertChild",
    value: function _insertChild(index, view) {
      if (this.anchor.parentNode) {
        var previousChild = this.children[index - 1];
        var previousElement = previousChild && previousChild.lastElement || this.anchor;
        view.insertAfter(previousElement);
      }
      this.children.insertAt(index, view);
    }
  }, {
    key: "_swapChildren",
    value: function _swapChildren(fromIndex, toIndex) {
      var last, _ref, _ref1, _ref2;
      if (this.anchor.parentNode) {
        last = ((_ref = this.children[fromIndex - 1]) != null ? _ref.lastElement : void 0) || this.anchor;
        this.children[toIndex].insertAfter(last);
        last = ((_ref1 = this.children[toIndex - 1]) != null ? _ref1.lastElement : void 0) || this.anchor;
        this.children[fromIndex].insertAfter(last);
      }
      return (_ref2 = [this.children[toIndex], this.children[fromIndex]], this.children[fromIndex] = _ref2[0], this.children[toIndex] = _ref2[1], _ref2);
    }
  }]);

  return CollectionView;
})(_dynamic_view2["default"]);

_compile2["default"].collection = function (ast, context) {
  return new CollectionView(ast, context);
};

exports["default"] = CollectionView;
module.exports = exports["default"];
