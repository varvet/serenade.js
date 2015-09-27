"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var _helpers = require("../helpers");

var BaseChannel = (function () {
  function BaseChannel() {
    _classCallCheck(this, BaseChannel);

    this.subscribers = [];
    this.trigger = this.trigger.bind(this);
  }

  _createClass(BaseChannel, [{
    key: "bind",
    value: function bind(cb) {
      this.subscribe(cb);
      cb(this.value);
    }
  }, {
    key: "once",
    value: function once(cb) {
      var _this = this;

      var handler = function handler(value) {
        cb(value);
        _this.unsubscribe(handler);
      };
      this.subscribe(handler);
    }
  }, {
    key: "gc",
    value: function gc(cb) {
      this.once(cb);
    }
  }, {
    key: "subscribe",
    value: function subscribe(callback) {
      if (!this.subscribers.length) {
        this._activate();
      }
      this.subscribers.push(callback);
    }
  }, {
    key: "unsubscribe",
    value: function unsubscribe(callback) {
      (0, _helpers.deleteItem)(this.subscribers, callback);
      if (!this.subscribers.length) {
        this._deactivate();
      }
    }
  }, {
    key: "trigger",
    value: function trigger() {
      var _this2 = this;

      this.subscribers.map(function (i) {
        return i;
      }).forEach(function (subscriber) {
        subscriber(_this2.value);
      });
    }
  }, {
    key: "_activate",
    value: function _activate() {}
  }, {
    key: "_deactivate",
    value: function _deactivate() {}
  }]);

  return BaseChannel;
})();

exports["default"] = BaseChannel;

BaseChannel.prototype.isChannel = true;
module.exports = exports["default"];
