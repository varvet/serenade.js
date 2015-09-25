import { merge } from "./helpers"
import Channel from "./channel"
import AttributeChannel from "./channel/attribute_channel"

export function defineChannel(object, name, options = {}) {
  let privateChannelName = "@" + name;
  let getter = options.channel || function() { return new Channel() };

  Object.defineProperty(object, name, {
    get: function() {
      if(!this.hasOwnProperty(privateChannelName)) {
        let channel = getter.call(this);
        Object.defineProperty(this, privateChannelName, {
          value: channel,
          configurable: true,
        });
      }
      return this[privateChannelName];
    },
    configurable: true
  })
}

export function defineAttribute(object, name, options) {
  options = merge({}, options);
  options.channelName = options.channelName || "@" + name;

  defineChannel(object, options.channelName, {
    channel() {
      return new AttributeChannel(this, options)
    }
  });

  function define(object) {
    Object.defineProperty(object, name, {
      get: function() {
        return this[options.channelName].value
      },
      set: function(value) {
        define(this);
        if(options.set) {
          options.set.call(this, value);
        } else {
          this[options.channelName].emit(value);
        }
      },
      enumerable: ("enumerable" in options) ? options.enumerable : true,
      configurable: true,
    })
  };

  define(object);

  if("value" in options) {
    object[name] = options.value;
  }
};

export function defineProperty(object, name, options = {}) {
  options.channelName = options.channelName || "@" + name;

  let deps = options.dependsOn;
  let getter = options.get || function() {};

  defineChannel(object, options.channelName, { channel() {
    let channel;
    if(deps) {
      deps = [].concat(deps);
      let dependentChannels = deps.map((d) => Channel.pluck(this, d));
      channel = Channel.all(dependentChannels).map((args) => getter.apply(this, args));
    } else {
      channel = Channel.static(this).map((val) => getter.call(val)).static();
    }
    if(options.cache) {
      channel = channel.cache();
    }
    channel = channel.async("property");
    return channel;
  }});

  options.get = function() {
    return this[options.channelName].value
  }
  options.configurable = true;

  Object.defineProperty(object, name, options);
};
