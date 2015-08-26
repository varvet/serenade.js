import Channel from "./channel"
import StaticChannel from "./static_channel"
import { deleteItem } from "../helpers"

export default class PluckedCollectionChannel extends StaticChannel {
  constructor(parent, property) {
    var oldCollection;
    var oldValues;
    super(undefined);
    this.parent = parent;
    this.property = property;
    this.subscribers = [];
    this.appliedHandler = () => {
      this.subscribers.forEach((cb) => cb(this.value));
    };
    this.handler = (values) => {
      if(oldValues) {
        oldValues.forEach((value) => {
          Channel.get(value, property).unsubscribe(this.appliedHandler);
        });
      }
      if(oldCollection && oldCollection.change) {
        oldCollection.change.unsubscribe(this.handler);
      }
      if(values) {
        if(values.change) {
          values.change.subscribe(this.handler);
        }
        values.forEach((value) => {
          Channel.get(value, property).subscribe(this.appliedHandler);
        });
        this.appliedHandler();
        oldValues = [].map.call(values, (x) => x)
      } else {
        oldValues = undefined;
      }
      oldCollection = values;
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

StaticChannel.prototype.pluckAll = function(property) {
  return new PluckedCollectionChannel(this, property);
}
