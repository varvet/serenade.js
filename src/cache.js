var Cache = {
	_identityMap: {},
	get: function(ctor, id) {
		var name, _ref;
		name = ctor.uniqueId();
		if (name && id) {
			return (_ref = this._identityMap[name]) != null ? _ref[id] : void 0;
		}
	},
	set: function(ctor, id, obj) {
		var name, _base;
		name = ctor.uniqueId();
		if (name && id) {
			(_base = this._identityMap)[name] || (_base[name] = {});
			return this._identityMap[name][id] = obj;
		}
	},
	unset: function(ctor, id) {
		var name, _base;
		name = ctor.uniqueId();
		if (name && id) {
			(_base = this._identityMap)[name] || (_base[name] = {});
			return delete this._identityMap[name][id];
		}
	}
};

export default Cache;
