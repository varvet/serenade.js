import Collection from "./collection"

class AssociationCollection extends Collection {
  constructor(owner, options, list) {
    super()
      this.owner = owner;
    this.options = options;
    this.splice(0, 0, ...list)
  }

  set(index, item) {
    return this._convert([item], ([item]) => super.set(item));
  };

  push(item) {
    return this._convert([item], ([item]) => super.push(item));
  };

  update(list) {
    return this._convert(list, (items) => super.update(items));
  };

  splice(start, deleteCount, ...list) {
    return this._convert(list, (items) => super.splice(start, deleteCount, ...items))
  };

  insertAt(index, item) {
    return this._convert([item], ([item]) => super.insertAt(index, item));
  };

  _convert(items, fn) {
    items = items.map((item) => {
      if(item && item.constructor === Object && this.options.as) {
        return new (this.options.as())(item)
      } else {
        return item
      }
    })

    let returnValue = fn(items)

      items.forEach((item) => {
        if(this.options.inverseOf && item[this.options.inverseOf] !== this.owner) {
          item[this.options.inverseOf] = this.owner;
        }
      });

    return returnValue;
  }
}

export default AssociationCollection;
