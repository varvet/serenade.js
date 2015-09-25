import { deleteItem } from "../helpers"

export default class BaseChannel {
  constructor() {
    this.subscribers = [];
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
    this.subscribers.push(callback);
  }

  unsubscribe(callback) {
    deleteItem(this.subscribers, callback);
  }

  trigger() {
    this.subscribers.map((i) => i).forEach((subscriber) => {
      subscriber(this.value);
    });
  }
}

BaseChannel.prototype.isChannel = true;
