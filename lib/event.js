"use strict";

Object.defineProperty(exports, "__esModule", {
	value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

exports["default"] = defineEvent;

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var _helpers = require("./helpers");

var Event = (function () {
	function Event(object, name, options) {
		_classCallCheck(this, Event);

		this.object = object;
		this.name = name;
		this.options = options;
	}

	_createClass(Event, [{
		key: "trigger",
		value: function trigger() {
			var _this = this;

			if (this.listeners.length) {
				for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
					args[_key] = arguments[_key];
				}

				this.queue.push(args);
				if (this.async) {
					if (this.options.animate) {
						if (!this.queue.frame) {
							this.queue.frame = requestAnimationFrame(function () {
								return _this.resolve();
							}, this.options.timeout || 0);
						}
					} else {
						if (this.queue.timeout && !this.options.buffer) {
							return;
						}
						if (this.options.timeout) {
							clearTimeout(this.queue.timeout);
							this.queue.timeout = setTimeout(function () {
								return _this.resolve();
							}, this.options.timeout || 0);
						} else if (!this.queue.tick) {
							this.queue.tick = true;
							(0, _helpers.nextTick)(function () {
								return _this.resolve();
							});
						}
					}
				} else {
					this.resolve();
				}
			}
		}
	}, {
		key: "bind",
		value: function bind(fun) {
			if (this.options.bind) {
				this.options.bind.call(this.object, fun);
			}
			(0, _helpers.safePush)(this.object._s, "listeners_" + this.name, fun);
		}
	}, {
		key: "one",
		value: function one(fun) {
			var unbind = this.unbind.bind(this);
			var handler = function handler() {
				unbind(handler);
				fun.apply(this, arguments);
			};
			this.bind(handler);
		}
	}, {
		key: "unbind",
		value: function unbind(fun) {
			(0, _helpers.safeDelete)(this.object._s, "listeners_" + this.name, fun);
			if (this.options.unbind) {
				this.options.unbind.call(this.object, fun);
			}
		}
	}, {
		key: "resolve",
		value: function resolve() {
			var _this2 = this;

			if (this.queue.frame) {
				cancelAnimationFrame(this.queue.frame);
			}
			clearTimeout(this.queue.timeout);
			if (this.queue.length) {
				(function () {
					var perform = function perform(args) {
						if (_this2.listeners) {
							[].concat(_this2.listeners).forEach(function (listener) {
								return listener.apply(_this2.object, args);
							});
						}
					};
					if (_this2.options.optimize) {
						perform(_this2.options.optimize(_this2.queue));
					} else {
						_this2.queue.forEach(function (args) {
							return perform(args);
						});
					}
				})();
			}
			this.queue = [];
		}
	}, {
		key: "async",
		get: function get() {
			if ("async" in this.options) {
				return this.options.async;
			} else {
				return _helpers.settings.async;
			}
		}
	}, {
		key: "listeners",
		get: function get() {
			return this.object._s["listeners_" + this.name] || [];
		}
	}, {
		key: "queue",
		get: function get() {
			if (!this.object._s.hasOwnProperty("queue_" + this.name)) {
				this.queue = [];
			}
			return this.object._s["queue_" + this.name];
		},
		set: function set(val) {
			this.object._s["queue_" + this.name] = val;
		}
	}]);

	return Event;
})();

exports.Event = Event;

function defineEvent(object, name, options) {
	if (options == null) {
		options = {};
	}
	if (!("_s" in object)) {
		(0, _helpers.defineOptions)(object, "_s");
	}
	Object.defineProperty(object, name, {
		configurable: true,
		get: function get() {
			return new Event(this, name, options);
		}
	});
}

;
