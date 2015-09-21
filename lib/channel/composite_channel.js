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

var CompositeChannel = (function (_StaticChannel) {
  function CompositeChannel(parents) {
    var _this = this;

    _classCallCheck(this, CompositeChannel);

    _get(Object.getPrototypeOf(CompositeChannel.prototype), "constructor", this).call(this, undefined);
    this.parents = parents;

    this.handler = function () {
      _this.subscribers.forEach(function (callback) {
        return callback(_this.value);
      });
    };
    this.subscribers = [];
  }

  _inherits(CompositeChannel, _StaticChannel);

  _createClass(CompositeChannel, [{
    key: "subscribe",
    value: function subscribe(callback) {
      var _this2 = this;

      if (!this.subscribers.length) {
        this.parents.forEach(function (parent) {
          return parent.subscribe(_this2.handler);
        });
      }
      this.subscribers.push(callback);
    }
  }, {
    key: "unsubscribe",
    value: function unsubscribe(callback) {
      var _this3 = this;

      _deleteItem.deleteItem(this.subscribers, callback);
      if (!this.subscribers.length) {
        this.parents.forEach(function (parent) {
          return parent.unsubscribe(_this3.handler);
        });
      }
    }
  }, {
    key: "value",
    get: function () {
      return this.parents.map(function (p) {
        return p.value;
      });
    },
    set: function (value) {}
  }]);

  return CompositeChannel;
})(_StaticChannel3["default"]);

exports["default"] = CompositeChannel;

_Channel2["default"].all = function (parents) {
  return new CompositeChannel(parents);
};
module.exports = exports["default"];

// No op
