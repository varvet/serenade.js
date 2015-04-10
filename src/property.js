import { def, maybe, extend, defineOptions, safePush, primitiveTypes } from "./helpers"
import { Event } from "./event"
import Collection from "./collection"

class PropertyDefinition {
	constructor(name, options) {
		extend(this, options);
		this.name = name;
		this.dependencies = [];
		this.localDependencies = [];
		this.globalDependencies = [];

    [].concat(this.dependsOn || []).forEach((name) => {
      if(this.dependencies.indexOf(name) === -1) {
        let subname, type;
        this.dependencies.push(name);
        if(name.match(/\./)) {
          type = "singular";
          [name, subname] = name.split(".");
        } else if (name.match(/:/)) {
          type = "collection";
          [name, subname] = name.split(":");
        }
        this.localDependencies.push(name);
        if(this.localDependencies.indexOf(name) === -1) this.localDependencies.push(name);
        if(type) this.globalDependencies.push({ subname, name, type });
      }
		});
	}

  get eventOptions() {
    let name = this.name;
    let options = {
      timeout: this.timeout,
      buffer: this.buffer,
      animate: this.animate,
      bind: function() {
        this[name + "_property"].registerGlobal();
      },
      optimize: (queue) => [queue[0][0], queue[queue.length - 1][1]]
    };
    if(this.hasOwnProperty("async")) options.async = this.async;

    return options;
	}
}

class PropertyAccessor {
	constructor(definition, object) {
    this.trigger = this.trigger.bind(this);
		this.definition = definition;
		this.object = object;
		this.name = this.definition.name;
		this.valueName = "_" + this.name;
		this.event = new Event(this.object, this.name + "_change", this.definition.eventOptions);
		this._gcQueue = [];
	}

	initialize(value) {
		this.update(value);
		this._oldValue = value;
	}

	update(value) {
		if(this.definition.set) {
			this.definition.set.call(this.object, value);
		} else {
			Object.defineProperty(this.object, this.valueName, { value: value, configurable: true, writable: true });
		}
	}

	set(value) {
		if(typeof value === "function") {
			this.definition.get = value;
		} else {
			this.update(value);
			this.trigger();
		}
	}

	get() {
		if (this.definition.get && !(this.definition.cache && this.valueName in this.object)) {
			let value = this.definition.get.call(this.object);
			if (this.definition.cache) {
				Object.defineProperty(this.object, this.valueName, { value, writable: true, configurable: true });
				if(!this._isCached) {
					this._isCached = true;
					this.bind(function() {});
				}
			}
      return value;
		} else {
			return this.object[this.valueName];
		}
	}

	registerGlobal(value) {
		if(this._isRegistered) return;
		this._isRegistered = true;

		if("_oldValue" in this) {
			if(arguments.length === 0) value = this.get();
			this._oldValue = value;
		}

		this.definition.globalDependencies.forEach(({ name, type, subname }) => {
      let trigger = this.trigger;

      if(type === "singular") {
        let updateItemBinding = function(before, after) {
          maybe(before).prop(subname + "_property").call("unbind", trigger);
          maybe(after).prop(subname + "_property").call("bind", trigger);
        };

        maybe(this.object[name + "_property"]).call("bind", updateItemBinding);
        updateItemBinding(undefined, this.object[name]);

        this._gcQueue.push(() => {
          updateItemBinding(this.object[name], undefined);
          maybe(this.object[name + "_property"]).call("unbind", updateItemBinding);
        });

      } else if(type == "collection") {
        function updateItemBindings(before, after) {
          maybe(before).call("forEach", (item) => {
            maybe(item[subname + "_property"]).call("unbind", trigger);
          });
          maybe(after).call("forEach", (item) => {
            maybe(item[subname + "_property"]).call("bind", trigger);
          });
        };

        function updateCollectionBindings(before, after) {
          updateItemBindings(before, after);
          maybe(before).prop("change").call("unbind", trigger);
          maybe(after).prop("change").call("bind", trigger);
          maybe(before).prop("change").call("unbind", updateItemBindings);
          maybe(after).prop("change").call("bind", updateItemBindings);
        };

        maybe(this.object[name + "_property"]).call("bind", updateCollectionBindings);
        updateCollectionBindings(undefined, this.object[name]);

        this._gcQueue.push(() => {
          updateCollectionBindings(this.object[name], undefined);
          maybe(this.object[name + "_property"]).call("unbind", updateCollectionBindings);
        });
			};
		});

		this.definition.localDependencies.forEach((dependency) => {
			maybe(this.object[dependency + "_property"]).call("registerGlobal")
		});
	}

	get hasListeners() {
    if(this.listeners.length) {
      return true;
    } else {
      return this.dependentProperties.some((prop) => prop.listeners.length);
    }
	}

	gc() {
		if (!this.hasListeners) {
      this._gcQueue.forEach((fn) => fn())
			this._isRegistered = false;
			this._gcQueue = [];
		}

    this.definition.localDependencies.forEach((dependency) => {
      maybe(this.object[dependency + "_property"]).call("gc");
    });
	};

	trigger() {
		this.clearCache();

    let retrievedNewValue, newValue;

		if(this.definition.changed === false) {
      return;
    } else if(this.definition.changed !== true) {
			if("_oldValue" in this) {
				if(this.definition.changed) {
					retrievedNewValue = true;
					newValue = this.get();
					if(!this.definition.changed.call(this.object, this._oldValue, newValue)) return;
				} else {
					retrievedNewValue = true;
					newValue = this.get();
					if(primitiveTypes.indexOf(typeof(this._oldValue) !== -1) && this._oldValue === newValue) return;
				}
			}
		}

		if (!retrievedNewValue) {
			newValue = this.get();
		}

		this.event.trigger(this._oldValue, newValue);

		let changes = {};
		changes[this.name] = newValue;

    maybe(this.object).prop("changed").call("trigger", changes)

    this.dependents.forEach((name) => {
			this.object[name + "_property"].trigger();
    });

		this._oldValue = newValue;
	}

  bind(fn) {
    this.event.bind(fn);
  }

  one(fn) {
    this.event.one(fn);
  }

  resolve(fn) {
    this.event.resolve(fn);
  }

	unbind(fn) {
		this.event.unbind(fn);
		this.gc();
	}

	get dependents() {
    let deps = [];
    let findDependencies = (name) => {
      this.object._s.properties.forEach((property) => {
        if(deps.indexOf(property.name) === -1 && property.localDependencies.indexOf(name) !== -1) {
          deps.push(property.name)
          findDependencies(property.name)
        }
      });
    };
    findDependencies(this.name);
    return deps;
	}

  get listeners() {
    return this.event.listeners;
	}

	clearCache() {
		if(this.definition.cache && this.definition.get) {
			delete this.object[this.valueName];
		}
	}

	get dependentProperties() {
    return new Collection(this.dependents.map((name) => this.object[name + "_property"]));
	}
}

function defineProperty(object, name, options) {
	var accessorName, define, definition;
	if (options == null) {
		options = {};
	}
	definition = new PropertyDefinition(name, options);
	if (!("_s" in object)) {
		defineOptions(object, "_s");
	}
	safePush(object._s, "properties", definition);
	define = function(object) {
		return def(object, name, {
			get: function() {
				return this[name + "_property"].get();
			},
			set: function(value) {
				define(this);
				return this[name + "_property"].set(value);
			},
			configurable: true,
			enumerable: "enumerable" in options ? options.enumerable : true
		});
	};
	define(object);
	accessorName = name + "_property";
	def(object, accessorName, {
		get: function() {
			if (!this._s.hasOwnProperty(accessorName)) {
				this._s[accessorName] = new PropertyAccessor(definition, this);
			}
			return this._s[accessorName];
		},
		configurable: true
	});
	if (typeof options.serialize === 'string') {
		defineProperty(object, options.serialize, {
			get: function() {
				return this[name];
			},
			set: function(v) {
				return this[name] = v;
			},
			configurable: true
		});
	}
	if ("value" in options) {
		return object[name] = options.value;
	}
};

export default defineProperty;
