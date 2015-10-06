import DynamicView from "./views/dynamic_view"
import Element from "./views/element"
import TextView from "./views/text_view"
import CollectionView from "./views/collection_view"
import Channel from "./channel"

export default {
  if(channel, options) {
    return DynamicView.bind(channel, (view, value) => {
      if(value) {
        view.replace([options.do.render(this)]);
      } else if(options.else) {
        view.replace([options.else.render(this)]);
      } else {
        view.clear()
      }
    });
  },

  unless(channel, options) {
    return DynamicView.bind(channel, (view, value) => {
      if(value) {
        view.clear()
      } else {
        view.replace([options.do.render(this)]);
      }
    });
  },

  in(channel, options) {
    return DynamicView.bind(channel, (view, value) => {
      if(value) {
        view.replace([options.do.render(value)]);
      } else {
        view.clear();
      }
    });
  },

  element(name, options) {
    return new Element(this, name, options);
  },

  content(channel) {
    return DynamicView.bind(channel, (view, value) => {
      if(value && value.isView) {
        view.replace([value]);
      } else {
        view.replace([new TextView(value)]);
      }
    });
  },

  collection(channel, options) {
    return new CollectionView(channel.collection(), options.do);
  },
}
