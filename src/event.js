import { defineOptions, safePush, safeDelete, settings, nextTick } from "./helpers"

export class Event {
	constructor(object, name, options) {
		this.object = object;
		this.name = name;
		this.options = options;
	}

	get async() {
    if("async" in this.options) {
      return this.options.async;
    } else {
      return settings.async;
    }
	}

	trigger(...args) {
		if (this.listeners.length) {
			this.queue.push(args);
			if(this.async) {
				if(this.options.animate) {
					if(!this.queue.frame) {
            this.queue.frame = requestAnimationFrame(() => this.resolve(), this.options.timeout || 0);
          }
				} else {
					if (this.queue.timeout && !this.options.buffer) {
						return;
					}
					if (this.options.timeout) {
						clearTimeout(this.queue.timeout);
						this.queue.timeout = setTimeout(() => this.resolve(), this.options.timeout || 0);
					} else if (!this.queue.tick) {
						this.queue.tick = true;
						nextTick(() => this.resolve());
					}
				}
			} else {
				this.resolve();
			}
		}
	}

	bind(fun) {
		if (this.options.bind) {
			this.options.bind.call(this.object, fun);
		}
		safePush(this.object._s, "listeners_" + this.name, fun);
	}

	one(fun) {
    var unbind = this.unbind.bind(this);
		var handler = function() {
			unbind(handler);
			fun.apply(this, arguments);
		};
		this.bind(handler);
	}

	unbind(fun) {
		safeDelete(this.object._s, "listeners_" + this.name, fun);
		if (this.options.unbind) {
			this.options.unbind.call(this.object, fun);
		}
	}

	resolve() {
    if(this.queue.frame) {
      cancelAnimationFrame(this.queue.frame)
    }
    clearTimeout(this.queue.timeout)
    if(this.queue.length) {
      let perform = (args) => {
        if(this.listeners) {
          ([].concat(this.listeners)).forEach((listener) => listener.apply(this.object, args))
        }
      };
      if(this.options.optimize) {
        perform(this.options.optimize(this.queue))
      } else {
        this.queue.forEach((args) => perform(args))
      }
    }
    this.queue = []
	}

	get listeners() {
    return this.object._s["listeners_" + this.name] || [];
	}

	get queue() {
    if (!this.object._s.hasOwnProperty("queue_" + this.name)) {
      this.queue = [];
    }
    return this.object._s["queue_" + this.name];
  }

  set queue(val) {
    this.object._s["queue_" + this.name] = val;
	}
}

export default function defineEvent(object, name, options) {
	if (options == null) {
		options = {};
	}
	if (!("_s" in object)) {
		defineOptions(object, "_s");
	}
	Object.defineProperty(object, name, {
		configurable: true,
		get: function() {
			return new Event(this, name, options);
		}
	});
};
