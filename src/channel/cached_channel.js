import BaseChannel from "./base_channel"

export default class CachedChannel extends BaseChannel {
  constructor(parent) {
    super();
    this.parent = parent;
    this.parent.subscribe(this._update.bind(this));
  }

  _update(value) {
    this._cache = value;
    this.trigger();
  }

  get value() {
    if(!("_cache" in this)) {
      this._cache = this.parent.value;
    }
    return this._cache;
  }

  expire() {
    delete this._cache;
  }
}

BaseChannel.prototype.cache = function(fn) {
  return new CachedChannel(this, fn);
}
