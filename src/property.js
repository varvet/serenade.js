import Channel from "./channel"

export function defineChannel(object, name, options = {}) {
  let privateChannelName = "@" + name;
  let getter = options.channel || function() { return new Channel(options) };

  Object.defineProperty(object, name, {
    get: function() {
      if(!this.hasOwnProperty(privateChannelName)) {
        Object.defineProperty(this, privateChannelName, {
          value: getter.call(this),
          configurable: true,
        });
      }
      return this[privateChannelName];
    },
    configurable: true
  })
}

export function defineAttribute(object, name, options) {
  let channelName = "@" + name;

  defineChannel(object, channelName, options);

	function define(object) {
    Object.defineProperty(object, name, {
      get: function() {
        return this[channelName].value
      },
      set: function(value) {
        define(this);
        if(options.set) {
          value = options.set.call(this, value)
        }
        this[channelName].emit(value);
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
  let channelName = "@" + name;
  let deps = options.dependsOn;
  let getter = options.get || function() {};

  if(deps) {
    deps = [].concat(deps);
    defineChannel(object, channelName, { channel() {
      let channels = deps.map((d) => Channel.pluck(this, d));
      return Channel.all(channels).map((args) => getter.apply(this, args));
    }});
  } else {
    defineChannel(object, channelName, { channel() {
      return Channel.static(getter.call(this));
    }});
  }

	function define(object) {
    Object.defineProperty(object, name, {
      get: function() {
        return this[channelName].value
      },
      set: options.set,
      enumerable: (options && "enumerable" in options) ? options.enumerable : true,
      configurable: (options && "configurable" in options) ? options.configurable : true,
    })
	};

	define(object);
};
