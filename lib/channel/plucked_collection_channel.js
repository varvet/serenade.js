"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var _channel = require("./channel");

var _channel2 = _interopRequireDefault(_channel);

var _base_channel = require("./base_channel");

var _base_channel2 = _interopRequireDefault(_base_channel);

var _derived_channel = require("./derived_channel");

var _derived_channel2 = _interopRequireDefault(_derived_channel);

var PluckedCollectionChannel = (function (_DerivedChannel) {
  _inherits(PluckedCollectionChannel, _DerivedChannel);

  function PluckedCollectionChannel(parent, property) {
    _classCallCheck(this, PluckedCollectionChannel);

    _get(Object.getPrototypeOf(PluckedCollectionChannel.prototype), "constructor", this).call(this, parent);
    this.property = property;
  }

  _createClass(PluckedCollectionChannel, [{
    key: "_update",
    value: function _update(values) {
      var _this = this;

      if (this._oldValues) {
        this._oldValues.forEach(function (value) {
          _channel2["default"].get(value, _this.property).unsubscribe(_this.trigger);
        });
      }
      if (values) {
        values.forEach(function (value) {
          _channel2["default"].get(value, _this.property).subscribe(_this.trigger);
        });
        this._oldValues = [].map.call(values, function (x) {
          return x;
        });
      } else {
        this._oldValues = undefined;
      }
    }
  }, {
    key: "value",
    get: function get() {
      var _this2 = this;

      return this.parent.value.map(function (value) {
        return _channel2["default"].get(value, _this2.property).value;
      });
    }
  }]);

  return PluckedCollectionChannel;
})(_derived_channel2["default"]);

exports["default"] = PluckedCollectionChannel;

_base_channel2["default"].prototype.pluckAll = function (property) {
  return new PluckedCollectionChannel(this.collection(), property);
};
module.exports = exports["default"];
