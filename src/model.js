import defineProperty from "./property"
import defineEvent from "./event"
import { def, serializeObject } from "./helpers"
import collection from "./model/collection"
import belongsTo from "./model/belongs_to"
import delegate from "./model/delegate"
import hasMany from "./model/has_many"
import selection from "./model/selection"
import Cache from "./cache"

var Model, idCounter,
	__hasProp = {}.hasOwnProperty,
	__extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	__slice = [].slice;

idCounter = 1;

Model = (function() {
	Model.identityMap = true;

	Model.collection = collection;
	Model.belongsTo = belongsTo;
	Model.delegate = delegate;
	Model.hasMany = hasMany;
	Model.selection = selection;

	Model.find = function(id) {
		return Cache.get(this, id) || new this({
			id: id
		});
	};

	Model.extend = function(ctor) {
		var New;
		return New = (function(_super) {
			__extends(New, _super);

			function New() {
				var val;
				val = New.__super__.constructor.apply(this, arguments);
				if (val) {
					return val;
				}
				if (ctor) {
					ctor.apply(this, arguments);
				}
			}

			return New;

		})(this);
	};

	Model.property = function() {
		var name, names, options, _i, _j, _len, _results;
		names = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), options = arguments[_i++];
		if (typeof options === "string") {
			names.push(options);
			options = {};
		}
		_results = [];
		for (_j = 0, _len = names.length; _j < _len; _j++) {
			name = names[_j];
			_results.push(defineProperty(this.prototype, name, options));
		}
		return _results;
	};

	Model.event = function(name, options) {
		return defineEvent(this.prototype, name, options);
	};

	Model.uniqueId = function() {
		if (!(this._uniqueId && this._uniqueGen === this)) {
			this._uniqueId = (idCounter += 1);
			this._uniqueGen = this;
		}
		return this._uniqueId;
	};

	Model.property('id', {
		serialize: true,
		set: function(val) {
			Cache.unset(this.constructor, this.id);
			Cache.set(this.constructor, val, this);
			return this._s.val_id = val;
		},
		get: function() {
			return this._s.val_id;
		}
	});

	Model.event("saved");

	Model.event("changed", {
		optimize: function(queue) {
			var item, result, _i, _len;
			result = {};
			for (_i = 0, _len = queue.length; _i < _len; _i++) {
				item = queue[_i];
				extend(result, item[0]);
			}
			return [result];
		}
	});

	function Model(attributes) {
		var fromCache, name, property, value;
		if (this.constructor.identityMap && (attributes != null ? attributes.id : void 0)) {
			fromCache = Cache.get(this.constructor, attributes.id);
			if (fromCache) {
				Model.prototype.set.call(fromCache, attributes);
				return fromCache;
			} else {
				Cache.set(this.constructor, attributes.id, this);
			}
		}
		for (name in attributes) {
			if (!__hasProp.call(attributes, name)) continue;
			value = attributes[name];
			property = this[name + "_property"];
			if (property) {
				property.initialize(value);
			} else {
				this[name] = value;
			}
		}
	}

	def(Model.prototype, "set", {
		configurable: true,
		writable: true,
		value: function(attributes) {
			var name, value, _results;
			_results = [];
			for (name in attributes) {
				if (!__hasProp.call(attributes, name)) continue;
				value = attributes[name];
				_results.push(this[name] = value);
			}
			return _results;
		}
	});

	def(Model.prototype, "save", {
		configurable: true,
		writable: true,
		value: function() {
			return this.saved.trigger();
		}
	});

	def(Model.prototype, "toJSON", {
		configurable: true,
		writable: true,
		value: function() {
			var key, property, serialized, value, _i, _len, _ref, _ref1;
			serialized = {};
			_ref = this._s.properties;
			for (_i = 0, _len = _ref.length; _i < _len; _i++) {
				property = _ref[_i];
				if (typeof property.serialize === 'string') {
					serialized[property.serialize] = serializeObject(this[property.name]);
				} else if (typeof property.serialize === 'function') {
					_ref1 = property.serialize.call(this), key = _ref1[0], value = _ref1[1];
					serialized[key] = serializeObject(value);
				} else if (property.serialize) {
					serialized[property.name] = serializeObject(this[property.name]);
				}
			}
			return serialized;
		}
	});

	def(Model.prototype, "toString", {
		configurable: true,
		writable: true,
		value: function() {
			return JSON.stringify(this.toJSON());
		}
	});

	return Model;

})();

export default Model;
