import { extend } from "./helpers"

import BaseChannel from "./channel/base_channel"
import Channel from "./channel/channel"
import StaticChannel from "./channel/static_channel"
import DerivedStaticChannel from "./channel/derived_static_channel"
import MappedChannel from "./channel/mapped_channel"
import AsyncChannel from "./channel/async_channel"
import CachedChannel from "./channel/cached_channel"
import PluckedChannel from "./channel/plucked_channel"
import CollectionChannel from "./channel/collection_channel"
import PluckedCollectionChannel from "./channel/plucked_collection_channel"
import CompositeChannel from "./channel/composite_channel"
import FilteredChannel from "./channel/filtered_channel"
import AttributeChannel from "./channel/attribute_channel"

extend(Channel, {
  all(parents) {
    return new CompositeChannel(parents);
  },

  of(value) {
    return new Channel(value);
  },

  static(value) {
    return new StaticChannel(value);
  },

  attribute(context, options, value) {
    return new AttributeChannel(context, options, value);
  },

  get(object, name) {
    let channelName = "@" + name;
    if(!object) {
      return new StaticChannel();
    } else if(object[channelName]) {
      return object[channelName];
    } else {
      return new StaticChannel(object[name]);
    }
  },

  pluck(object, name) {
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
  },
});

extend(BaseChannel.prototype, {
  map(fn) {
    return new MappedChannel(this, fn);
  },

  pluckAll(property) {
    return new PluckedCollectionChannel(this.collection(), property);
  },

  pluck(property) {
    return new PluckedChannel(this, property);
  },

  filter(fn) {
    return new FilteredChannel(this, fn);
  },

  static() {
    return new DerivedStaticChannel(this);
  },

  async(queue) {
    return new AsyncChannel(this, queue);
  },

  cache(fn) {
    return new CachedChannel(this, fn);
  },

  collection() {
    return new CollectionChannel(this);
  },
});

export default Channel
