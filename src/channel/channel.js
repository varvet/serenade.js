import StaticChannel from "./static_channel"

export default class Channel extends StaticChannel {
  static of(value) {
    return new Channel(value);
  }

  static static(value) {
    return new StaticChannel(value);
  }

  static get(object, name) {
    let channelName = "~" + name;
    if(!object) {
      return new StaticChannel();
    } else if(object[channelName]) {
      return object[channelName];
    } else {
      return new StaticChannel(object[name]);
    }
  }

  static pluck(object, name) {
    let parts = name.split(/[\.:]/)

    if(parts.length == 2) {
      if(name.match(/:/)) {
        return Channel.get(object, parts[0]).pluckAll(parts[1]);
      } else {
        return Channel.get(object, parts[0]).pluck(parts[1]);
      }
    } else if(parts.length == 1) {
      return Channel.get(object, name);
    } else {
      throw new Error("cannot pluck more than one level in depth");
    }
  }

  constructor(value, options = {}) {
    super(value)
    this.options = options;
    this._subscribers = [];
  }

  emit(value) {
    this.value = value;
    this.trigger();
  }

  trigger() {
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
