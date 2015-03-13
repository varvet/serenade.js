import Collection from "./collection"

var AssociationCollection,
	__hasProp = {}.hasOwnProperty,
	__extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	__slice = [].slice;

AssociationCollection = (function(_super) {
	__extends(AssociationCollection, _super);

	function AssociationCollection(owner, options, list) {
		this.owner = owner;
		this.options = options;
		this._convert.apply(this, __slice.call(list).concat([(function(_this) {
			return function() {
				var items;
				items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
				return AssociationCollection.__super__.constructor.call(_this, items);
			};
		})(this)]));
	}

	AssociationCollection.prototype.set = function(index, item) {
		return this._convert(item, (function(_this) {
			return function(item) {
				return AssociationCollection.__super__.set.call(_this, index, item);
			};
		})(this));
	};

	AssociationCollection.prototype.push = function(item) {
		return this._convert(item, (function(_this) {
			return function(item) {
				return AssociationCollection.__super__.push.call(_this, item);
			};
		})(this));
	};

	AssociationCollection.prototype.update = function(list) {
		return this._convert.apply(this, __slice.call(list).concat([(function(_this) {
			return function() {
				var items;
				items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
				return AssociationCollection.__super__.update.call(_this, items);
			};
		})(this)]));
	};

	AssociationCollection.prototype.splice = function() {
		var deleteCount, list, start;
		start = arguments[0], deleteCount = arguments[1], list = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
		return this._convert.apply(this, __slice.call(list).concat([(function(_this) {
			return function() {
				var items;
				items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
				return AssociationCollection.__super__.splice.apply(_this, [start, deleteCount].concat(__slice.call(items)));
			};
		})(this)]));
	};

	AssociationCollection.prototype.insertAt = function(index, item) {
		return this._convert(item, (function(_this) {
			return function(item) {
				return AssociationCollection.__super__.insertAt.call(_this, index, item);
			};
		})(this));
	};

	AssociationCollection.prototype._convert = function() {
		var fn, item, items, returnValue, _i, _j, _len;
		items = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), fn = arguments[_i++];
		items = (function() {
			var _j, _len, _results;
			_results = [];
			for (_j = 0, _len = items.length; _j < _len; _j++) {
				item = items[_j];
				if ((item != null ? item.constructor : void 0) === Object && this.options.as) {
					_results.push(item = new (this.options.as())(item));
				} else {
					_results.push(item);
				}
			}
			return _results;
		}).call(this);
		returnValue = fn.apply(null, items);
		for (_j = 0, _len = items.length; _j < _len; _j++) {
			item = items[_j];
			if (this.options.inverseOf && item[this.options.inverseOf] !== this.owner) {
				item[this.options.inverseOf] = this.owner;
			}
		}
		return returnValue;
	};

	return AssociationCollection;

})(Collection);

export default AssociationCollection;
