"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var _helpers = require("./helpers");

var _collection = require("./collection");

var _collection2 = _interopRequireDefault(_collection);

var _event_queue = require("./event_queue");

var _event_queue2 = _interopRequireDefault(_event_queue);

var EventManager = (function () {
  _createClass(EventManager, null, [{
    key: "default",
    value: function _default() {
      var manager = new EventManager();
      manager.push("attribute");
      manager.push("property");
      manager.push("render");
      return manager;
    }
  }]);

  function EventManager() {
    _classCallCheck(this, EventManager);

    this.tick = this.tick.bind(this);
    this.queues = {};
    this.list = [];
  }

  _createClass(EventManager, [{
    key: "push",
    value: function push(name) {
      var queue = new _event_queue2["default"](this, name);
      this.list.push(queue);
      this.queues[name] = queue;
    }
  }, {
    key: "tick",
    value: function tick() {
      this.frame = null;
      this.list.forEach(function (queue) {
        return queue.tick();
      });
    }
  }, {
    key: "ping",
    value: function ping() {
      if (_helpers.settings.async) {
        if (!this.frame) {
          this.frame = requestAnimationFrame(this.tick);
        }
      } else {
        this.tick();
      }
    }
  }]);

  return EventManager;
})();

exports["default"] = EventManager;
module.exports = exports["default"];
