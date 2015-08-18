import Channel from "./channel"
import StaticChannel from "./static_channel"

export default class AppliedChannel extends StaticChannel {
  constructor(parent, property) {
    var oldValue;
    super(undefined);
    this.parent = parent;
    this.property = property;
    this.channelName = "~" + property;
    this.appliedHandler = (value) => {
      this.channel.emit(value);
    };
    this.handler = (value) => {
      this._fetch(oldValue).unsubscribe(this.appliedHandler);
      this._fetch(value).bind(this.appliedHandler);
      oldValue = value;
    };
    this.channel = new Channel(undefined);
    this.handler(parent.value);
  }

  subscribe(callback) {
    if(!this.channel._subscribers.length) {
      this.parent.subscribe(this.handler)
    }
    this.channel.subscribe(callback);
  }

  unsubscribe(callback) {
    this.channel.unsubscribe(callback);
    if(!this.channel._subscribers.length) {
      this.parent.unsubscribe(this.handler)
    }
  }

  get value() {
    return this.channel.value;
  }

  set value(value) {
    // No op
  }

  _fetch(object) {
    if(!object) {
      return new StaticChannel();
    } else if(object[this.channelName]) {
      return object[this.channelName];
    } else {
      return new StaticChannel(object[this.property]);
    }
  }
}

StaticChannel.prototype.apply = function(property) {
  return new AppliedChannel(this, property);
}
