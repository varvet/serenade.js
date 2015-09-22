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

var _TemplateView = require("./template_view");

var _TemplateView2 = _interopRequireDefault(_TemplateView);

var _TextView = require("./text_view");

var _TextView2 = _interopRequireDefault(_TextView);

var _Compile = require("../compile");

var _Compile2 = _interopRequireDefault(_Compile);

var _Collection = require("../collection");

var _Collection2 = _interopRequireDefault(_Collection);

var _Transform = require("../transform");

var _Transform2 = _interopRequireDefault(_Transform);

var CollectionView = (function (_DynamicView) {
  function CollectionView(ast, context) {
    var _this = this;

    _classCallCheck(this, CollectionView);

    _get(Object.getPrototypeOf(CollectionView.prototype), "constructor", this).call(this, ast, context);

    if (ast.arguments.length !== 1) {
      throw new Error("`in` must take exactly one argument");
    }

    var channel = _Compile2["default"].parameter(ast.arguments[0], context).collection();
    this._bind(channel, function (values) {
      if (values && values.length) {
        if (_this.lastItems && _this.lastItems.length) {
          _this.replace(values);
        } else {
          _this.children = new _Collection2["default"](values.map(_this._toView.bind(_this)));
          _this.rebuild();
        }
        _this.lastItems = values.map(function (i) {
          return i;
        });
      } else if (_this.lastItems && _this.lastItems.length) {
        _this.clear();
        _this.lastItems = undefined;
      }
    });
  }

  _inherits(CollectionView, _DynamicView);

  _createClass(CollectionView, [{
    key: "replace",
    value: function replace(items) {
      var _this2 = this;

      _Transform2["default"](this.lastItems, items).forEach(function (operation) {
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
        return new _TemplateView2["default"](this.ast.children || [], item);
      } else if (item && item.isView) {
        return item;
      } else {
        return new _TextView2["default"](item);
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
        var a = view.children[0];
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
})(_DynamicView3["default"]);

_Compile2["default"].collection = function (ast, context) {
  return new CollectionView(ast, context);
};

exports["default"] = CollectionView;
module.exports = exports["default"];
