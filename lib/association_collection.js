"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _slicedToArray = function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"]) _i["return"](); } finally { if (_d) throw _e; } } return _arr; } else { throw new TypeError("Invalid attempt to destructure non-iterable instance"); } };

var _toConsumableArray = function (arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i]; return arr2; } else { return Array.from(arr); } };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(object, property, receiver) { var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

var _inherits = function (subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; };

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _Collection2 = require("./collection");

var _Collection3 = _interopRequireDefault(_Collection2);

var AssociationCollection = (function (_Collection) {
  function AssociationCollection(owner, options, list) {
    _classCallCheck(this, AssociationCollection);

    _get(Object.getPrototypeOf(AssociationCollection.prototype), "constructor", this).call(this);
    this.owner = owner;
    this.options = options;
    this.splice.apply(this, [0, 0].concat(_toConsumableArray(list)));
  }

  _inherits(AssociationCollection, _Collection);

  _createClass(AssociationCollection, [{
    key: "set",
    value: function set(index, item) {
      var _this = this;

      return this._convert([item], function (_ref) {
        var _ref2 = _slicedToArray(_ref, 1);

        var item = _ref2[0];
        return _get(Object.getPrototypeOf(AssociationCollection.prototype), "set", _this).call(_this, item);
      });
    }
  }, {
    key: "push",
    value: function push(item) {
      var _this2 = this;

      return this._convert([item], function (_ref3) {
        var _ref32 = _slicedToArray(_ref3, 1);

        var item = _ref32[0];
        return _get(Object.getPrototypeOf(AssociationCollection.prototype), "push", _this2).call(_this2, item);
      });
    }
  }, {
    key: "update",
    value: function update(list) {
      var _this3 = this;

      return this._convert(list, function (items) {
        return _get(Object.getPrototypeOf(AssociationCollection.prototype), "update", _this3).call(_this3, items);
      });
    }
  }, {
    key: "splice",
    value: function splice(start, deleteCount) {
      for (var _len = arguments.length, list = Array(_len > 2 ? _len - 2 : 0), _key = 2; _key < _len; _key++) {
        list[_key - 2] = arguments[_key];
      }

      var _this4 = this;

      return this._convert(list, function (items) {
        var _get2;

        return (_get2 = _get(Object.getPrototypeOf(AssociationCollection.prototype), "splice", _this4)).call.apply(_get2, [_this4, start, deleteCount].concat(_toConsumableArray(items)));
      });
    }
  }, {
    key: "insertAt",
    value: function insertAt(index, item) {
      var _this5 = this;

      return this._convert([item], function (_ref4) {
        var _ref42 = _slicedToArray(_ref4, 1);

        var item = _ref42[0];
        return _get(Object.getPrototypeOf(AssociationCollection.prototype), "insertAt", _this5).call(_this5, index, item);
      });
    }
  }, {
    key: "_convert",
    value: function _convert(items, fn) {
      var _this6 = this;

      items = items.map(function (item) {
        if (item && item.constructor === Object && _this6.options.as) {
          return new (_this6.options.as())(item);
        } else {
          return item;
        }
      });

      var returnValue = fn(items);

      items.forEach(function (item) {
        if (_this6.options.inverseOf && item[_this6.options.inverseOf] !== _this6.owner) {
          item[_this6.options.inverseOf] = _this6.owner;
        }
      });

      return returnValue;
    }
  }]);

  return AssociationCollection;
})(_Collection3["default"]);

exports["default"] = AssociationCollection;
module.exports = exports["default"];
