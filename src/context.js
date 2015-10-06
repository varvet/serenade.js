import Element from "./views/element"
import TextView from "./views/text_view"
import CollectionView from "./views/collection_view"
import Channel from "./channel"

export default {
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
    return channel.map((value) => {
      if(value && value.isView) {
        return value;
      } else {
        return new TextView(value);
      }
    });
  },

  collection(channel, options) {
    return new CollectionView(channel.collection(), options.do);
  },
}
