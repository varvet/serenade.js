"use strict";

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

Object.defineProperty(exports, "__esModule", {
  value: true
});

var StaticChannel = (function () {
  function StaticChannel(value) {
    _classCallCheck(this, StaticChannel);

    this.value = value;
  }

  _createClass(StaticChannel, [{
    key: "subscribe",
    value: function subscribe(cb) {}
  }, {
    key: "unsubscribe",
    value: function unsubscribe(cb) {}
  }, {
    key: "bind",
    value: function bind(cb) {
      this.subscribe(cb);
      cb(this.value);
    }
  }, {
    key: "once",
    value: function once(cb) {
      var _this = this;

      var handler = (function (_handler) {
        function handler(_x) {
          return _handler.apply(this, arguments);
        }

        handler.toString = function () {
          return _handler.toString();
        };

        return handler;
      })(function (value) {
        cb(value);
        _this.unsubscribe(handler);
      });
      this.subscribe(handler);
    }
  }]);

  return StaticChannel;
})();

exports["default"] = StaticChannel;

StaticChannel.prototype.isChannel = true;
module.exports = exports["default"];
