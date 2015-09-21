"use strict";

Object.defineProperty(exports, "__esModule", {
	value: true
});
var Cache = {
	_identityMap: {},

	get: function get(ctor, id) {
		var name = ctor.uniqueId();
		if (name && id) {
			var map = this._identityMap[name];
			return map && map[id];
		}
	},

	set: function set(ctor, id, obj) {
		var name = ctor.uniqueId();
		if (name && id) {
			var map = this._identityMap[name];
			if (!map) {
				map = {};
				this._identityMap[name] = map;
			}
			map[id] = obj;
		}
	},

	unset: function unset(ctor, id) {
		var name = ctor.uniqueId();
		if (name && id) {
			var map = this._identityMap[name];
			if (map) {
				delete map[id];
			}
		}
	}
};

exports["default"] = Cache;
module.exports = exports["default"];
