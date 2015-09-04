export default class StaticChannel {
  constructor(value) {
    this.value = value;
  }

  subscribe(cb) {
  }

  unsubscribe(cb) {
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
}

StaticChannel.prototype.isChannel = true;
