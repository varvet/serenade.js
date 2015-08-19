import Channel from "./channel"
import StaticChannel from "./static_channel"

export default class AppliedCollectionChannel extends StaticChannel {
  constructor(parent, property) {
    var oldValues;
    super(undefined);
    this.parent = parent;
    this.property = property;
    this.appliedHandler = () => {
      this.channel.emit(this.value);
    };
    this.handler = (values) => {
      if(oldValues) {
        oldValues.forEach((value) => {
          Channel.get(value, property).unsubscribe(this.appliedHandler);
        });
      }
      if(values) {
        values.forEach((value) => {
          Channel.get(value, property).bind(this.appliedHandler);
        });
      }
      oldValues = [].concat(values);
    };
    this.channel = new Channel(undefined);
    this.handler(parent.value);
  }

  subscribe(callback) {
    if(!this.channel._subscribers.length) {
      this.parent.bind(this.handler)
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
    return this.parent.value.map((value) => {
      return Channel.get(value, this.property).value
    });
  }

  set value(value) {
    // No op
  }
}

StaticChannel.prototype.applyAll = function(property) {
  return new AppliedCollectionChannel(this, property);
}
