"use strict";

Object.defineProperty(exports, "__esModule", {
	value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i]; return arr2; } else { return Array.from(arr); } }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var _channel = require("./channel");

var _channel2 = _interopRequireDefault(_channel);

var _helpers = require("./helpers");

var Collection = (function () {
	_createClass(Collection, [{
		key: "first",
		get: function get() {
			return this[0];
		}
	}, {
		key: "last",
		get: function get() {
			return this[this.length - 1];
		}
	}]);

	function Collection(list) {
		_classCallCheck(this, Collection);

		this.change = new _channel2["default"]();
		if (list) {
			for (var index = 0; index < list.length; index++) {
				this[index] = list[index];
			}
			this.length = list.length;
		} else {
			this.length = 0;
		}
	}

	_createClass(Collection, [{
		key: "get",
		value: function get(index) {
			return this[index];
		}
	}, {
		key: "set",
		value: function set(index, value) {
			Array.prototype.splice.call(this, index, 1, value);
			return value;
		}
	}, {
		key: "update",
		value: function update(list) {
			Array.prototype.splice.apply(this, [0, this.length].concat(Array.prototype.slice.call(list)));
			return this;
		}
	}, {
		key: "sortBy",
		value: function sortBy(attribute) {
			return this.sort(function (a, b) {
				return a[attribute] < b[attribute] ? -1 : 1;
			});
		}
	}, {
		key: "includes",
		value: function includes(item) {
			return this.indexOf(item) >= 0;
		}
	}, {
		key: "find",
		value: function find(fun) {
			for (var index = 0; index < this.length; index++) {
				var item = this[index];
				if (fun(item)) {
					return item;
				}
			}
		}
	}, {
		key: "insertAt",
		value: function insertAt(index, value) {
			Array.prototype.splice.call(this, index, 0, value);
			return value;
		}
	}, {
		key: "deleteAt",
		value: function deleteAt(index) {
			var value = this[index];
			Array.prototype.splice.call(this, index, 1);
			return value;
		}
	}, {
		key: "delete",
		value: function _delete(item) {
			var index = this.indexOf(item);
			if (index !== -1) {
				return this.deleteAt(index);
			}
		}
	}, {
		key: "concat",
		value: function concat() {
			var _toArray;

			for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
				args[_key] = arguments[_key];
			}

			args = args.map(function (arg) {
				if (arg instanceof Collection) {
					return arg.toArray();
				} else {
					return arg;
				}
			});
			return new Collection((_toArray = this.toArray()).concat.apply(_toArray, _toConsumableArray(args)));
		}
	}, {
		key: "toArray",
		value: function toArray() {
			return Array.prototype.slice.call(this);
		}
	}, {
		key: "clone",
		value: function clone() {
			return new Collection(this.toArray());
		}
	}, {
		key: "toString",
		value: function toString() {
			return this.toArray().toString();
		}
	}, {
		key: "toLocaleString",
		value: function toLocaleString() {
			return this.toArray().toLocaleString();
		}
	}, {
		key: "toJSON",
		value: function toJSON() {
			return (0, _helpers.serializeObject)(this.toArray());
		}
	}]);

	return Collection;
})();

Object.getOwnPropertyNames(Array.prototype).forEach(function (fun) {
	if (!Collection.prototype[fun]) {
		Collection.prototype[fun] = Array.prototype[fun];
	}
});

["splice", "map", "filter", "slice"].forEach(function (fun) {
	var original = Collection.prototype[fun];
	Collection.prototype[fun] = function () {
		for (var _len2 = arguments.length, args = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
			args[_key2] = arguments[_key2];
		}

		return new Collection(original.apply(this, args));
	};
});

["push", "pop", "unshift", "shift", "splice", "sort", "reverse", "update", "set", "insertAt", "deleteAt"].forEach(function (fun) {
	var original = Collection.prototype[fun];
	Collection.prototype[fun] = function () {
		var old = this.clone();

		for (var _len3 = arguments.length, args = Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
			args[_key3] = arguments[_key3];
		}

		var val = original.apply(this, args);
		this.change.emit(this);
		return val;
	};
});

exports["default"] = Collection;
module.exports = exports["default"];
