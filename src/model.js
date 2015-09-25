import { defineProperty, defineAttribute, defineChannel } from "./property"
import collection from "./model/collection"
import belongsTo from "./model/belongs_to"
import delegate from "./model/delegate"
import hasMany from "./model/has_many"
import selection from "./model/selection"
import Cache from "./cache"

let idCounter = 1;

class Model {
	static find(id) {
		return Cache.get(this, id) || new this({ id });
	}

	static extend(ctor) {
    class New extends this {
      constructor(...args) {
        let value = super(...args)
        if(value) return value;
        if(ctor) {
          ctor.apply(this, args);
        }
      }
    };
    return New;
	}

	static attribute(...names) {
    let options;
		if (typeof names[names.length - 1] !== "string") {
      options = names.pop();
		} else {
      options = {}
    }
    names.forEach((name) => defineAttribute(this.prototype, name, options));
	}

	static property(name, options) {
    defineProperty(this.prototype, name, options);
	}

	static channel(name, options) {
		defineChannel(this.prototype, name, options);
	}

	static uniqueId() {
		if (!(this._uniqueId && this._uniqueGen === this)) {
			this._uniqueId = (idCounter += 1);
			this._uniqueGen = this;
		}
		return this._uniqueId;
	}

	constructor(attributes = {}) {
		if(this.constructor.identityMap && attributes && attributes.id) {
			let fromCache = Cache.get(this.constructor, attributes.id);
			if(fromCache) {
				Model.prototype.set.call(fromCache, attributes);
				return fromCache;
			} else {
				Cache.set(this.constructor, attributes.id, this);
			}
		}
    Object.keys(attributes).forEach((name) => {
			this[name] = attributes[name];
		});
	}

	set(attributes) {
    for(let name in attributes) {
      if(!attributes.hasOwnProperty(name)) continue;
      this[name] = attributes[name];
    }
	}

	save() {
    this.saved.trigger();
  }

	toJSON() {
    let result = {};
    Object.keys(this).forEach((key) => result[key] = this[key])
    return result;
	}

	toString() {
    return JSON.stringify(this.toJSON());
	}
}

["property", "attribute", "channel", "uniqueId", "extend", "find"].forEach((prop) => {
  Object.defineProperty(Model, prop, {
    enumerable: true,
    configurable: true,
    writable: true,
    value: Model[prop]
  });
});

Model.attribute('id', {
  set: function(val) {
    Cache.unset(this.constructor, this.id);
    Cache.set(this.constructor, val, this);
    this["@id"].emit(val);
  }
});

Model.channel("saved");

Model.channel("changed", {
  optimize: function(queue) {
    let result = {};
    queue.forEach((item) => extend(result, item[0]));
    return [result];
  }
});

Model.identityMap = true;
Model.collection = collection;
Model.belongsTo = belongsTo;
Model.delegate = delegate;
Model.hasMany = hasMany;
Model.selection = selection;

export default Model;
