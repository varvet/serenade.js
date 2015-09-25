import BaseChannel from "./base_channel"
import DerivedChannel from "./derived_channel"

export default class CollectionChannel extends DerivedChannel {
  constructor(parent) {
    super(parent);
  }

  update(collection) {
    if(this._oldCollection && this._oldCollection.change) {
      this._oldCollection.change.unsubscribe(this.handler);
    }
    if(collection && collection.change) {
      collection.change.subscribe(this.handler);
    }
    this._oldCollection = collection;
  }

  handler(collection) {
    this.update(collection);
    this.trigger();
  };

  _activate() {
    super._activate();
    this.update(this.parent.value);
  }

  _deactivate() {
    super._deactivate();
    this.update(undefined)
  }

  get value() {
    return this.parent.value
  }
}

BaseChannel.prototype.collection = function() {
  return new CollectionChannel(this);
}
