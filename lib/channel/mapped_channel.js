"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(object, property, receiver) { var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

var _inherits = function (subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; };

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _StaticChannel2 = require("./static_channel");

var _StaticChannel3 = _interopRequireDefault(_StaticChannel2);

var _deleteItem = require("../helpers");

var MappedChannel = (function (_StaticChannel) {
  function MappedChannel(parent, fn) {
    var _this = this;

    _classCallCheck(this, MappedChannel);

    _get(Object.getPrototypeOf(MappedChannel.prototype), "constructor", this).call(this, undefined);
    this.subscribers = [];
    this.fn = fn;
    this.parent = parent;
    this.handler = function (value) {
      _this.subscribers.forEach(function (callback) {
        callback(_this.value);
      });
    };
  }

  _inherits(MappedChannel, _StaticChannel);

  _createClass(MappedChannel, [{
    key: "subscribe",
    value: function subscribe(callback) {
      if (!this.subscribers.length) {
        this.parent.subscribe(this.handler);
      }
      this.subscribers.push(callback);
    }
  }, {
    key: "unsubscribe",
    value: function unsubscribe(callback) {
      _deleteItem.deleteItem(this.subscribers, callback);
      if (!this.subscribers.length) {
        this.parent.unsubscribe(this.handler);
      }
    }
  }, {
    key: "value",
    get: function () {
      return this.fn(this.parent.value);
    },
    set: function (value) {}
  }]);

  return MappedChannel;
})(_StaticChannel3["default"]);

exports["default"] = MappedChannel;

_StaticChannel3["default"].prototype.map = function (fn) {
  return new MappedChannel(this, fn);
};
module.exports = exports["default"];

// No op
