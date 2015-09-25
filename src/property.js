import Channel from "./channel"
import AttributeChannel from "./channel/attribute_channel"

function normalizeOptions(object, name, options = {}) {
  if(!("changed" in options)) {
    options.changed = function(oldVal, newVal) { return oldVal !== newVal };
  } else if(typeof(options.changed) !== "function") {
    let value = options.changed;
    options.changed = function() { return value };
  }
  options.channelName = options.channelName || "@" + name;
  return options;
}

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
  options = normalizeOptions(object, name, options);

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
        this[options.channelName].emit(value);
      },
      enumerable: (options && "enumerable" in options) ? options.enumerable : true,
      configurable: (options && "configurable" in options) ? options.configurable : true,
    })
	};

	define(object);

  if(options && "value" in options) {
    object[name] = options.value;
  }
};

export function defineProperty(object, name, options) {
  options = normalizeOptions(object, name, options);
  let deps = options.dependsOn;
  let getter = options.get || function() {};

  if(deps) {
    deps = [].concat(deps);
    defineChannel(object, options.channelName, { channel() {
      let dependentChannels = deps.map((d) => Channel.pluck(this, d));
      let channel = Channel.all(dependentChannels).map((args) => getter.apply(this, args));
      return channel;
    }});
  } else {
    defineChannel(object, options.channelName, { channel() {
      return Channel.static(getter.call(this));
    }});
  }

  Object.defineProperty(object, name, {
    get: function() {
      return this[options.channelName].value
    },
    set: options.set,
    enumerable: (options && "enumerable" in options) ? options.enumerable : false,
    configurable: (options && "configurable" in options) ? options.configurable : true,
  })
};
