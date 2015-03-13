import { def, extend, defineOptions, safePush, primitiveTypes } from "./helpers"
import { Event } from "./event"

var PropertyAccessor, PropertyDefinition, defineProperty,
	__bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
	__indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

PropertyDefinition = (function() {
	function PropertyDefinition(name, options) {
		var subname, type, _i, _len, _ref, _ref1, _ref2;
		this.name = name;
		extend(this, options);
		this.dependencies = [];
		this.localDependencies = [];
		this.globalDependencies = [];
		if (this.dependsOn) {
			_ref = [].concat(this.dependsOn);
			for (_i = 0, _len = _ref.length; _i < _len; _i++) {
				name = _ref[_i];
				if (this.dependencies.indexOf(name) === -1) {
					this.dependencies.push(name);
					if (name.match(/\./)) {
						type = "singular";
						_ref1 = name.split("."), name = _ref1[0], subname = _ref1[1];
					} else if (name.match(/:/)) {
						type = "collection";
						_ref2 = name.split(":"), name = _ref2[0], subname = _ref2[1];
					}
					this.localDependencies.push(name);
					if (this.localDependencies.indexOf(name) === -1) {
						this.localDependencies.push(name);
					}
					if (type) {
						this.globalDependencies.push({
							subname: subname,
							name: name,
							type: type
						});
					}
				}
			}
		}
	}

	def(PropertyDefinition.prototype, "eventOptions", {
		get: function() {
			var name, options;
			name = this.name;
			options = {
				timeout: this.timeout,
				buffer: this.buffer,
				animate: this.animate,
				bind: function() {
					return this[name + "_property"].registerGlobal();
				},
				optimize: function(queue) {
					var _ref, _ref1;
					return [(_ref = queue[0]) != null ? _ref[0] : void 0, (_ref1 = queue[queue.length - 1]) != null ? _ref1[1] : void 0];
				}
			};
			if (this.async != null) {
				options.async = this.async;
			}
			return options;
		}
	});

	return PropertyDefinition;

})();

PropertyAccessor = (function() {
	function PropertyAccessor(definition, object) {
		this.definition = definition;
		this.object = object;
		this.trigger = __bind(this.trigger, this);
		this.name = this.definition.name;
		this.valueName = "_" + this.name;
		this.event = new Event(this.object, this.name + "_change", this.definition.eventOptions);
		this._gcQueue = [];
	}

	PropertyAccessor.prototype.initialize = function(value) {
		this.update(value);
		return this._oldValue = value;
	};

	PropertyAccessor.prototype.update = function(value) {
		if (this.definition.set) {
			return this.definition.set.call(this.object, value);
		} else {
			return def(this.object, this.valueName, {
				value: value,
				configurable: true,
				writable: true
			});
		}
	};

	PropertyAccessor.prototype.set = function(value) {
		if (typeof value === "function") {
			return this.definition.get = value;
		} else {
			this.update(value);
			return this.trigger();
		}
	};

	PropertyAccessor.prototype.get = function() {
		var value;
		if (this.definition.get && !(this.definition.cache && this.valueName in this.object)) {
			value = this.definition.get.call(this.object);
			if (this.definition.cache) {
				def(this.object, this.valueName, {
					value: value,
					writable: true,
					configurable: true
				});
				if (!this._isCached) {
					this._isCached = true;
					this.bind(function() {});
				}
			}
		} else {
			value = this.object[this.valueName];
		}
		return value;
	};

	PropertyAccessor.prototype.registerGlobal = function(value) {
		var dependency, _i, _len, _ref, _ref1, _results;
		if (this._isRegistered) {
			return;
		}
		this._isRegistered = true;
		if ("_oldValue" in this) {
			if (arguments.length === 0) {
				value = this.get();
			}
			this._oldValue = value;
		}
		this.definition.globalDependencies.forEach((function(_this) {
			return function(_arg) {
				var name, subname, type, updateCollectionBindings, updateItemBinding, updateItemBindings, _ref, _ref1;
				name = _arg.name, type = _arg.type, subname = _arg.subname;
				switch (type) {
					case "singular":
						updateItemBinding = function(before, after) {
							var _ref, _ref1;
							if (before != null) {
								if ((_ref = before[subname + "_property"]) != null) {
									_ref.unbind(_this.trigger);
								}
							}
							return after != null ? (_ref1 = after[subname + "_property"]) != null ? _ref1.bind(_this.trigger) : void 0 : void 0;
						};
						if ((_ref = _this.object[name + "_property"]) != null) {
							_ref.bind(updateItemBinding);
						}
						updateItemBinding(void 0, _this.object[name]);
						return _this._gcQueue.push(function() {
							var _ref1;
							updateItemBinding(_this.object[name], void 0);
							return (_ref1 = _this.object[name + "_property"]) != null ? _ref1.unbind(updateItemBinding) : void 0;
						});
					case "collection":
						updateItemBindings = function(before, after) {
							if (before != null) {
								if (typeof before.forEach === "function") {
									before.forEach(function(item) {
										var _ref1;
										return (_ref1 = item[subname + "_property"]) != null ? _ref1.unbind(_this.trigger) : void 0;
									});
								}
							}
							return after != null ? typeof after.forEach === "function" ? after.forEach(function(item) {
								var _ref1;
								return (_ref1 = item[subname + "_property"]) != null ? _ref1.bind(_this.trigger) : void 0;
							}) : void 0 : void 0;
						};
						updateCollectionBindings = function(before, after) {
							var _ref1, _ref2, _ref3, _ref4;
							updateItemBindings(before, after);
							if (before != null) {
								if ((_ref1 = before.change) != null) {
									_ref1.unbind(_this.trigger);
								}
							}
							if (after != null) {
								if ((_ref2 = after.change) != null) {
									_ref2.bind(_this.trigger);
								}
							}
							if (before != null) {
								if ((_ref3 = before.change) != null) {
									_ref3.unbind(updateItemBindings);
								}
							}
							return after != null ? (_ref4 = after.change) != null ? _ref4.bind(updateItemBindings) : void 0 : void 0;
						};
						if ((_ref1 = _this.object[name + "_property"]) != null) {
							_ref1.bind(updateCollectionBindings);
						}
						updateCollectionBindings(void 0, _this.object[name]);
						return _this._gcQueue.push(function() {
							var _ref2;
							updateCollectionBindings(_this.object[name], void 0);
							return (_ref2 = _this.object[name + "_property"]) != null ? _ref2.unbind(updateCollectionBindings) : void 0;
						});
				}
			};
		})(this));
		_ref = this.definition.localDependencies;
		_results = [];
		for (_i = 0, _len = _ref.length; _i < _len; _i++) {
			dependency = _ref[_i];
			_results.push((_ref1 = this.object[dependency + "_property"]) != null ? _ref1.registerGlobal() : void 0);
		}
		return _results;
	};

	def(PropertyAccessor.prototype, "hasListeners", {
		get: function() {
			return this.listeners.length === 0 && !this.dependentProperties.find((function(_this) {
				return function(prop) {
					return prop.listeners.length !== 0;
				};
			})(this));
		}
	});

	PropertyAccessor.prototype.gc = function() {
		var dependency, fn, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results;
		if (this.hasListeners) {
			_ref = this._gcQueue;
			for (_i = 0, _len = _ref.length; _i < _len; _i++) {
				fn = _ref[_i];
				fn();
			}
			this._isRegistered = false;
			this._gcQueue = [];
		}
		_ref1 = this.definition.localDependencies;
		_results = [];
		for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
			dependency = _ref1[_j];
			_results.push((_ref2 = this.object[dependency + "_property"]) != null ? _ref2.gc() : void 0);
		}
		return _results;
	};

	PropertyAccessor.prototype.trigger = function() {
		var changes, name, newValue, retrievedNewValue, _i, _len, _ref, _ref1, _ref2, _ref3;
		this.clearCache();
		if ((_ref = this.definition.changed) === true || _ref === false) {
			if (!this.definition.changed) {
				return;
			}
		} else {
			if ("_oldValue" in this) {
				if (this.definition.changed) {
					retrievedNewValue = true;
					newValue = this.get();
					if (!this.definition.changed.call(this.object, this._oldValue, newValue)) {
						return;
					}
				} else {
					retrievedNewValue = true;
					newValue = this.get();
					if (_ref1 = typeof this._oldValue, __indexOf.call(primitiveTypes, _ref1) >= 0) {
						if (this._oldValue === newValue) {
							return;
						}
					}
				}
			}
		}
		if (!retrievedNewValue) {
			newValue = this.get();
		}
		this.event.trigger(this._oldValue, newValue);
		changes = {};
		changes[this.name] = newValue;
		if ((_ref2 = this.object.changed) != null) {
			if (typeof _ref2.trigger === "function") {
				_ref2.trigger(changes);
			}
		}
		_ref3 = this.dependents;
		for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
			name = _ref3[_i];
			this.object[name + "_property"].trigger();
		}
		return this._oldValue = newValue;
	};

	["bind", "one", "resolve"].forEach(function(fn) {
		return PropertyAccessor.prototype[fn] = function() {
			var _ref;
			return (_ref = this.event)[fn].apply(_ref, arguments);
		};
	});

	PropertyAccessor.prototype.unbind = function(fn) {
		this.event.unbind(fn);
		return this.gc();
	};

	def(PropertyAccessor.prototype, "dependents", {
		get: function() {
			var deps, findDependencies;
			deps = [];
			findDependencies = (function(_this) {
				return function(name) {
					var property, _i, _len, _ref, _ref1, _results;
					_ref = _this.object._s.properties;
					_results = [];
					for (_i = 0, _len = _ref.length; _i < _len; _i++) {
						property = _ref[_i];
						if ((_ref1 = property.name, __indexOf.call(deps, _ref1) < 0) && __indexOf.call(property.localDependencies, name) >= 0) {
							deps.push(property.name);
							_results.push(findDependencies(property.name));
						} else {
							_results.push(void 0);
						}
					}
					return _results;
				};
			})(this);
			findDependencies(this.name);
			return deps;
		}
	});

	def(PropertyAccessor.prototype, "listeners", {
		get: function() {
			return this.event.listeners;
		}
	});

	PropertyAccessor.prototype.clearCache = function() {
		if (this.definition.cache && this.definition.get) {
			return delete this.object[this.valueName];
		}
	};

	def(PropertyAccessor.prototype, "dependentProperties", {
		get: function() {
			var name;
			return new Serenade.Collection((function() {
				var _i, _len, _ref, _results;
				_ref = this.dependents;
				_results = [];
				for (_i = 0, _len = _ref.length; _i < _len; _i++) {
					name = _ref[_i];
					_results.push(this.object[name + "_property"]);
				}
				return _results;
			}).call(this));
		}
	});

	return PropertyAccessor;

})();

defineProperty = function(object, name, options) {
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
