class StaticChannel {
  static of(value) {
    new StaticChannel(value)
  }

  constructor(value) {
    this.value = value;
  }

  bind(callback) {
    callback(this.value);
  }

  subscribe() {} // No op
  unsubscribe() {} // No op
  once() {} // No op
  resolve() {} // No op

  map(fn) {
    return new StaticChannel(fn(this.value))
  }

  filter(fn) {
    if(fn(this.value)) {
      return new StaticChannel(this.value)
    } else {
      return new StaticChannel(undefined)
    }
  }
}
