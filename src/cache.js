var Cache = {
  _identityMap: {},

  get: function(ctor, id) {
    let name = ctor.uniqueId();
    if (name && id) {
      let map = this._identityMap[name];
      return map && map[id];
    }
  },

  set: function(ctor, id, obj) {
    let name = ctor.uniqueId();
    if(name && id) {
      let map = this._identityMap[name];
      if(!map) {
        map = {};
        this._identityMap[name] = map;
      }
      map[id] = obj;
    }
  },

  unset: function(ctor, id) {
    let name = ctor.uniqueId();
    if(name && id) {
      let map = this._identityMap[name];
      if(map) {
        delete map[id];
      }
    }
  }
};

export default Cache;
