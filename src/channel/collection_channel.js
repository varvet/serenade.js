import DerivedChannel from "./derived_channel"

export default class CollectionChannel extends DerivedChannel {
  constructor(parent) {
    super(parent);
  }

  _update(collection) {
    if(this._oldCollection && this._oldCollection.change) {
      this._oldCollection.change.unsubscribe(this._handler);
    }
    if(collection && collection.change) {
      collection.change.subscribe(this._handler);
    }
    this._oldCollection = collection;
  }
}
