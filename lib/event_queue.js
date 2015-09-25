"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var EventQueue = (function () {
  function EventQueue(manager, name) {
    _classCallCheck(this, EventQueue);

    this.manager = manager;
    this.name = name;
    this.channels = [];
  }

  _createClass(EventQueue, [{
    key: "tick",
    value: function tick() {
      for (var i = 0; i < this.channels.length; i++) {
        this.channels[i].trigger();
      }
      this.channels.forEach(function (channel) {
        return channel.reset();
      });
      this.channels = [];
    }
  }, {
    key: "enqueue",
    value: function enqueue(channel) {
      this.channels.push(channel);
      this.manager.ping();
    }
  }]);

  return EventQueue;
})();

exports["default"] = EventQueue;
module.exports = exports["default"];
