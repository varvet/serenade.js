import DynamicView from "./views/dynamic_view"
import Element from "./views/element"
import ContentView from "./views/content_view"

export default {
  if(channel, options) {
    let view = new DynamicView()
    channel.bind((value) => {
      if(value) {
        view.replace([options.do.render(this)]);
      } else {
        view.clear()
      }
    });
  },

  element(name, options) {
    return new Element(this, name, options);
  },

  content(channel) {
    return new ContentView(channel);
  },
}
