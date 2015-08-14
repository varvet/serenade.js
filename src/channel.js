// Channels are streams of values which have a current value and allow
// operations over its values.

class Channel {
  static of(value) {
    let channel = new Channel();
    channel.emit(value);
    return channel;
  }

  static all(parents) {
    let channel = new Channel()
    let value = () => parents.map((p) => p.value)
    parents.forEach((parent) => {
      parent.subscribe(() => channel.emit(value()));
    });
    channel.emit(value());
    return channel;
  }

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

  bind(callback) {
    this.subscribe(callback);
    callback(this.value);
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

  once(callback) {
    let handler = (value) => {
      callback(value);
      this.unsubscribe(handler);
    }
    this.subscribe(handler);
  }

  resolve() {
    this._subscribers.forEach((subscriber) => {
      subscriber(this.value);
    });
  }

  map(fn) {
    let channel = new Channel(fn(this.value), this.options);
    this.bind((value) => channel.emit(fn(value)));
    return channel;
  }

  filter(fn) {
    let channel = new Channel(this.options);
    this.bind((value) => {
      if(fn(value)) {
        channel.emit(value);
      }
    });
    return channel;
  }
}

module.exports = Channel
