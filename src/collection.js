import Channel from "./channel"
import { serializeObject } from "./helpers"

class Collection {
	get first() {
    return this[0];
	}

  get last() {
    return this[this.length - 1];
	}

	constructor(list) {
    this.change = new Channel()
		if(list) {
      for(let index = 0; index < list.length; index++) {
        this[index] = list[index];
      }
			this.length = list.length;
		} else {
			this.length = 0;
		}
	}

	get(index) {
		return this[index];
	}

	set(index, value) {
		Array.prototype.splice.call(this, index, 1, value);
		return value;
	}

	update(list) {
		Array.prototype.splice.apply(this, [0, this.length].concat(Array.prototype.slice.call(list)));
		return this;
	}

	sortBy(attribute) {
		return this.sort((a, b) => a[attribute] < b[attribute] ? -1 : 1)
	}

	includes(item) {
		return this.indexOf(item) >= 0;
	}

	find(fun) {
    for(let index = 0; index < this.length; index++) {
			let item = this[index];
			if(fun(item)) {
				return item;
			}
		}
	}

	insertAt(index, value) {
		Array.prototype.splice.call(this, index, 0, value);
		return value;
	}

	deleteAt(index) {
		let value = this[index];
		Array.prototype.splice.call(this, index, 1);
		return value;
	}

	delete(item) {
		let index = this.indexOf(item);
		if(index !== -1) {
			return this.deleteAt(index);
		}
	}

	concat(...args) {
		args = args.map((arg) => {
      if(arg instanceof Collection) {
        return arg.toArray();
      } else {
        return arg;
      }
		});
		return new Collection(this.toArray().concat(...args));
	}

	toArray() {
		return Array.prototype.slice.call(this);
	}

	clone() {
		return new Collection(this.toArray());
	}

	toString() {
		return this.toArray().toString();
	}

	toLocaleString() {
		return this.toArray().toLocaleString();
	}
}

Object.getOwnPropertyNames(Array.prototype).forEach((fun) => {
  if(!Collection.prototype[fun]) {
    Collection.prototype[fun] = Array.prototype[fun]
  }
});

["splice", "map", "filter", "slice"].forEach(function(fun) {
  let original = Collection.prototype[fun];
  Collection.prototype[fun] = function(...args) {
    return new Collection(original.apply(this, args));
  };
});

["push", "pop", "unshift", "shift", "splice", "sort", "reverse", "update", "set", "insertAt", "deleteAt"].forEach(function(fun) {
  let original = Collection.prototype[fun];
  Collection.prototype[fun] = function(...args) {
    let val = original.apply(this, args);
    this.change.emit(this);
    return val;
  };
});

export default Collection;
