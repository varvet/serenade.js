import Element from "./views/element"
import TextView from "./views/text_view"
import CollectionView from "./views/collection_view"
import Channel from "./channel"

let context = {
  if(channel, options) {
    return channel.map((value) => {
      if(value) {
        return options.do.render(this);
      } else if(options.else) {
        return options.else.render(this);
      }
    });
  },

  unless(channel, options) {
    return channel.map((value) => {
      if(!value) {
        return options.do.render(this);
      }
    });
  },

  in(channel, options) {
    return channel.map((value) => {
      if(value) {
        return options.do.render(value);
      }
    });
  },

  element(name, options) {
    return new Element(this, name, options);
  },

  content(channel) {
    return channel;
  },

  collection(channel, options) {
    return new CollectionView(channel.collection(), options.do);
  },

  coalesce(...args) {
    return Channel.all(args).map((args) => args.join(" "));
  },

  join(...args) {
    return Channel.all(args).map(([elements, divider]) => {
      return elements.join(divider);
    });
  },

  toUpperCase(channel) {
    return channel.map((val) => val.toUpperCase());
  },

  toLowerCase(channel) {
    return channel.map((val) => val.toLowerCase());
  },
};

["px"].forEach((unit) => {
  context[unit] = function(channel) {
    return channel.map((val) => val + unit);
  };
});

export default context;
