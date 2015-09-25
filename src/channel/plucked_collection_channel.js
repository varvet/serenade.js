import Channel from "./channel"
import BaseChannel from "./base_channel"
import { deleteItem } from "../helpers"

export default class PluckedCollectionChannel extends BaseChannel {
  constructor(parent, property) {
    var oldValues;
    super(undefined);
    this.parent = parent;
    this.property = property;
    this.subscribers = [];
    this.handler = (values) => {
      if(oldValues) {
        oldValues.forEach((value) => {
          Channel.get(value, property).unsubscribe(this.trigger);
        });
      }
      if(values) {
        values.forEach((value) => {
          Channel.get(value, property).subscribe(this.trigger);
        });
        this.trigger();
        oldValues = [].map.call(values, (x) => x)
      } else {
        oldValues = undefined;
      }
    };
  }

  subscribe(cb) {
    if(!this.subscribers.length) {
      this.parent.bind(this.handler);
    }
    this.subscribers.push(cb);
  }

  unsubscribe(cb) {
    deleteItem(this.subscribers, cb);
    if(!this.subscribers.length) {
      this.parent.unsubscribe(this.handler);
      this.handler(undefined);
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

BaseChannel.prototype.pluckAll = function(property) {
  return new PluckedCollectionChannel(this.collection(), property);
}
