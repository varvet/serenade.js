"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(object, property, receiver) { var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

var _inherits = function (subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; };

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _Channel = require("./channel");

var _Channel2 = _interopRequireDefault(_Channel);

var _StaticChannel2 = require("./static_channel");

var _StaticChannel3 = _interopRequireDefault(_StaticChannel2);

var _deleteItem = require("../helpers");

var PluckedChannel = (function (_StaticChannel) {
  function PluckedChannel(parent, property) {
    var _this = this;

    _classCallCheck(this, PluckedChannel);

    var oldValue;
    _get(Object.getPrototypeOf(PluckedChannel.prototype), "constructor", this).call(this, undefined);
    this.parent = parent;
    this.property = property;
    this.appliedHandler = function (value) {
      _this.subscribers.forEach(function (cb) {
        return cb(_this.value);
      });
    };
    this.handler = function (value) {
      _Channel2["default"].get(oldValue, property).unsubscribe(_this.appliedHandler);
      _Channel2["default"].get(value, property).bind(_this.appliedHandler);
      oldValue = value;
    };
    this.subscribers = [];
  }

  _inherits(PluckedChannel, _StaticChannel);

  _createClass(PluckedChannel, [{
    key: "subscribe",
    value: function subscribe(cb) {
      if (!this.subscribers.length) {
        this.parent.bind(this.handler);
      }
      this.subscribers.push(cb);
    }
  }, {
    key: "unsubscribe",
    value: function unsubscribe(cb) {
      _deleteItem.deleteItem(this.subscribers, cb);
      if (!this.subscribers.length) {
        this.parent.unsubscribe(this.handler);
        this.handler(undefined);
      }
    }
  }, {
    key: "value",
    get: function () {
      return _Channel2["default"].get(this.parent.value, this.property).value;
    },
    set: function (value) {}
  }]);

  return PluckedChannel;
})(_StaticChannel3["default"]);

exports["default"] = PluckedChannel;

_StaticChannel3["default"].prototype.pluck = function (property) {
  return new PluckedChannel(this, property);
};
module.exports = exports["default"];

// No op
