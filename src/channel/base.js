import MapChannel from "./map_channel"

export default class BaseChannel {
  constructor(options = {}) {
    this.options = options;
    this._subscribers = [];
  }

  subscribe(callback) {
  }

  unsubscribe(callback) {
  }

  bind(callback) {
    this.subscribe(callback);
    callback(this.value);
  }

  once(callback) {
    let handler = (value) => {
      callback(value);
      this.unsubscribe(handler);
    }
    this.subscribe(handler);
  }

  map(fn) {
    return new MapChannel(this, fn);
  }
}
