import defineEvent from "./event"
import { def, serializeObject } from "./helpers"

var Collection,
	__slice = [].slice;

Collection = (function() {
	defineEvent(Collection.prototype, "change");

	def(Collection.prototype, "first", {
		get: function() {
			return this[0];
		}
	});

	def(Collection.prototype, "last", {
		get: function() {
			return this[this.length - 1];
		}
	});

	function Collection(list) {
		var index, val, _i, _len;
		if (list) {
			for (index = _i = 0, _len = list.length; _i < _len; index = ++_i) {
				val = list[index];
				this[index] = val;
			}
			this.length = list.length;
		} else {
			this.length = 0;
		}
	}

	Collection.prototype.get = function(index) {
		return this[index];
	};

	Collection.prototype.set = function(index, value) {
		Array.prototype.splice.call(this, index, 1, value);
		return value;
	};

	Collection.prototype.update = function(list) {
		Array.prototype.splice.apply(this, [0, this.length].concat(Array.prototype.slice.call(list)));
		return this;
	};

	Collection.prototype.sortBy = function(attribute) {
		return this.sort(function(a, b) {
			if (a[attribute] < b[attribute]) {
				return -1;
			} else {
				return 1;
			}
		});
	};

	Collection.prototype.includes = function(item) {
		return this.indexOf(item) >= 0;
	};

	Collection.prototype.find = function(fun) {
		var item, _i, _len;
		for (_i = 0, _len = this.length; _i < _len; _i++) {
			item = this[_i];
			if (fun(item)) {
				return item;
			}
		}
	};

	Collection.prototype.insertAt = function(index, value) {
		Array.prototype.splice.call(this, index, 0, value);
		return value;
	};

	Collection.prototype.deleteAt = function(index) {
		var value;
		value = this[index];
		Array.prototype.splice.call(this, index, 1);
		return value;
	};

	Collection.prototype["delete"] = function(item) {
		var index;
		index = this.indexOf(item);
		if (index !== -1) {
			return this.deleteAt(index);
		}
	};

	Collection.prototype.concat = function() {
		var arg, args, _ref;
		args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
		args = (function() {
			var _i, _len, _results;
			_results = [];
			for (_i = 0, _len = args.length; _i < _len; _i++) {
				arg = args[_i];
				if (arg instanceof Collection) {
					_results.push(arg.toArray());
				} else {
					_results.push(arg);
				}
			}
			return _results;
		})();
		return new Collection((_ref = this.toArray()).concat.apply(_ref, args));
	};

	Collection.prototype.toArray = function() {
		return Array.prototype.slice.call(this);
	};

	Collection.prototype.clone = function() {
		return new Collection(this.toArray());
	};

	Collection.prototype.toString = function() {
		return this.toArray().toString();
	};

	Collection.prototype.toLocaleString = function() {
		return this.toArray().toLocaleString();
	};

	Collection.prototype.toJSON = function() {
		return serializeObject(this.toArray());
	};

	Object.getOwnPropertyNames(Array.prototype).forEach(function(fun) {
		var _base;
		return (_base = Collection.prototype)[fun] || (_base[fun] = Array.prototype[fun]);
	});

	["splice", "map", "filter", "slice"].forEach(function(fun) {
		var original;
		original = Collection.prototype[fun];
		return Collection.prototype[fun] = function() {
			return new Collection(original.apply(this, arguments));
		};
	});

	["push", "pop", "unshift", "shift", "splice", "sort", "reverse", "update", "set", "insertAt", "deleteAt"].forEach(function(fun) {
		var original;
		original = Collection.prototype[fun];
		return Collection.prototype[fun] = function() {
			var old, val;
			old = this.clone();
			val = original.apply(this, arguments);
			this.change.trigger(old, this);
			return val;
		};
	});

	return Collection;

})();

export default Collection;
