import BaseChannel from "./base_channel"

export default class DerivedChannel extends BaseChannel {
  constructor(parent, fn) {
    super();
    this.parent = parent;
    this._handler = this._handler.bind(this);
  }

  get value() {
    return this.parent.value;
  }

  expire() {
    this.parent.expire();
  }

  _handler(value) {
    this._update(value)
    this.trigger()
  }

  _update(value) { }

  _activate() {
    this.parent.subscribe(this._handler)
    this._update(this.parent.value);
  }

  _deactivate() {
    this.parent.unsubscribe(this._handler)
    this._update(undefined);
  }
}
