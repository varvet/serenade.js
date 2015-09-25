import { deleteItem } from "../helpers"

export default class BaseChannel {
  constructor() {
    this.subscribers = [];
    this.trigger = this.trigger.bind(this);
  }

  bind(cb) {
    this.subscribe(cb);
    cb(this.value);
  }

  once(cb) {
    let handler = (value) => {
      cb(value);
      this.unsubscribe(handler);
    }
    this.subscribe(handler);
  }

  emit(value) {
    this.value = value;
    this.trigger();
  }

  subscribe(callback) {
    if(!this.subscribers.length) {
      this._activate()
    }
    this.subscribers.push(callback);
  }

  unsubscribe(callback) {
    deleteItem(this.subscribers, callback);
    if(!this.subscribers.length) {
      this._deactivate()
    }
  }

  trigger() {
    this.subscribers.map((i) => i).forEach((subscriber) => {
      subscriber(this.value);
    });
  }

  _activate() {}
  _deactivate() {}
}

BaseChannel.prototype.isChannel = true;
