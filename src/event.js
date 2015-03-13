import { def, defineOptions, safePush, safeDelete, settings, nextTick } from "./helpers"

var Event, defineEvent,
	__slice = [].slice;

Event = (function() {
	function Event(object, name, options) {
		this.object = object;
		this.name = name;
		this.options = options;
	}

	def(Event.prototype, "async", {
		get: function() {
			if ("async" in this.options) {
				return this.options.async;
			} else {
				return settings.async;
			}
		}
	});

	Event.prototype.trigger = function() {
		var args, _base;
		args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
		if (this.listeners.length) {
			this.queue.push(args);
			if (this.async) {
				if (this.options.animate) {
					return (_base = this.queue).frame || (_base.frame = requestAnimationFrame(((function(_this) {
						return function() {
							return _this.resolve();
						};
					})(this)), this.options.timeout || 0));
				} else {
					if (this.queue.timeout && !this.options.buffer) {
						return;
					}
					if (this.options.timeout) {
						clearTimeout(this.queue.timeout);
						return this.queue.timeout = setTimeout(((function(_this) {
							return function() {
								return _this.resolve();
							};
						})(this)), this.options.timeout || 0);
					} else if (!this.queue.tick) {
						this.queue.tick = true;
						return nextTick((function(_this) {
							return function() {
								return _this.resolve();
							};
						})(this));
					}
				}
			} else {
				return this.resolve();
			}
		}
	};

	Event.prototype.bind = function(fun) {
		if (this.options.bind) {
			this.options.bind.call(this.object, fun);
		}
		return safePush(this.object._s, "listeners_" + this.name, fun);
	};

	Event.prototype.one = function(fun) {
		var handler = function() {
			this.unbind(this);
			fun.apply(this, arguments);
		}.bind(this);
		this.bind(handler);
	};

	Event.prototype.unbind = function(fun) {
		safeDelete(this.object._s, "listeners_" + this.name, fun);
		if (this.options.unbind) {
			return this.options.unbind.call(this.object, fun);
		}
	};

	Event.prototype.resolve = function() {
		var args, perform, _i, _len, _ref;
		if (this.queue.frame) {
			cancelAnimationFrame(this.queue.frame);
		}
		clearTimeout(this.queue.timeout);
		if (this.queue.length) {
			perform = (function(_this) {
				return function(args) {
					if (_this.listeners) {
						return ([].concat(_this.listeners)).forEach(function(listener) {
							return listener.apply(_this.object, args);
						});
					}
				};
			})(this);
			if (this.options.optimize) {
				perform(this.options.optimize(this.queue));
			} else {
				_ref = this.queue;
				for (_i = 0, _len = _ref.length; _i < _len; _i++) {
					args = _ref[_i];
					perform(args);
				}
			}
		}
		return this.queue = [];
	};

	def(Event.prototype, "listeners", {
		get: function() {
			return this.object._s["listeners_" + this.name] || [];
		}
	});

	def(Event.prototype, "queue", {
		get: function() {
			if (!this.object._s.hasOwnProperty("queue_" + this.name)) {
				this.queue = [];
			}
			return this.object._s["queue_" + this.name];
		},
		set: function(val) {
			return this.object._s["queue_" + this.name] = val;
		}
	});

	return Event;

})();

defineEvent = function(object, name, options) {
	if (options == null) {
		options = {};
	}
	if (!("_s" in object)) {
		defineOptions(object, "_s");
	}
	return def(object, name, {
		configurable: true,
		get: function() {
			return new Event(this, name, options);
		}
	});
};

export { Event };
export default defineEvent;
