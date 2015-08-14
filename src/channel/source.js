import BaseChannel from "./base_channel"

export default class SourceChannel extends BaseChannel {
  constructor(options = {}) {
    this.options = options;
    this._subscribers = [];
  }

  emit(value) {
    this.value = value;
    if(this.options.async) {
      if(!this.timeout) {
        this.timeout = requestAnimationFrame(() => { this.resolve() });
      }
    } else {
      this.resolve();
    }
  }

  subscribe(callback) {
    this._subscribers.push(callback);
  }

  unsubscribe(callback) {
    let index = this._subscribers.indexOf(callback);
    if(index !== -1) {
      this._subscribers.splice(index, 1)
    }
  }

  resolve() {
    this._subscribers.forEach((subscriber) => {
      subscriber(this.value);
    });
  }
}
