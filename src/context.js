import Element from "./views/element"
import CollectionView from "./views/collection_view"
import { helper } from "./decorators"

let context = {
  __element(name, options) {
    return new Element(this, name, options);
  },

  __content(channel) {
    return channel;
  },

  @helper
  if(value, options) {
    if(value) {
      return options.do.render(this);
    } else if(options.else) {
      return options.else.render(this);
    }
  },

  @helper
  unless(value, options) {
    if(!value) {
      return options.do.render(this);
    }
  },

  in(channel, options) {
    return channel.map((value) => {
      if(value) {
        return options.do.render(value);
      }
    });
  },

  collection(channel, options) {
    return new CollectionView(channel.collection(), options.do);
  },

  @helper
  coalesce(...args) {
    return args.join(" ");
  },

  @helper
  join(elements, divider) {
    return elements.join(divider);
  },

  @helper
  toUpperCase(value) {
    return value.toUpperCase();
  },

  @helper
  toLowerCase(value) {
    return value.toLowerCase();
  },

  @helper
  url(value) {
    return "url(" + value + ")";
  },

  @helper
  percent(value) {
    return value + "%";
  },
};


"em,ex,px,cm,mm,pt,pc,ch,rem,vh,vw,vm,vmin,vmax,deg,rad,grad,turn,ms,s".split(",").forEach((unit) => {
  context[unit] = function(channel) {
    return channel.map((val) => val + unit);
  };
});

export default context;
