export default class StaticChannel {
  constructor(value) {
    this.value = value;
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
}
