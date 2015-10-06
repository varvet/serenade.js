import View from "./view"
import { defineChannel } from "../property"
import { settings, assignUnlessEqual } from "../helpers"
import Collection from "../collection"
import Channel from "../channel"

const Property = {
  style: {
    update: function(channel, value) {
      assignUnlessEqual(this.node.style, channel.name, value);
    }
  },
  event: {
    setup: function(channel) {
      this.node.addEventListener(channel.name, (e) => {
        if(channel.preventDefault) {
          e.preventDefault();
        }
        this.context[channel.property](this.node, this.context, e);
      });
    }
  },
  class: {
    update: function(channel, value) {
      if(value) {
        if(!this.boundClasses) {
          this.boundClasses = new Collection();
        }
        if(!this.boundClasses.includes(channel.name)) {
          this.boundClasses.push(channel.name);
          this._updateClass();
        }
      } else if(this.boundClasses) {
        let index = this.boundClasses.indexOf(channel.name);
        this.boundClasses.delete(channel.name);
        this._updateClass();
      }
    }
  },
  binding: {
    setup: function(channel) {
      if(this.type !== "input" && this.type !== "textarea" && this.type !== "select") {
        throw SyntaxError("invalid view type " + this.type + " for two way binding");
      }
      if(!channel.property) {
        throw SyntaxError("cannot bind to whole context, please specify an attribute to bind to");
      }
      let setValue = (newValue) => {
        let currentValue = this.context[channel.property];
        if(currentValue && currentValue.isChannel) {
          currentValue.emit(newValue);
        } else {
          this.context[channel.property] = newValue
        }
      }
      let domUpdated = () => {
        if(this.node.type === "checkbox") {
          setValue(this.node.checked);
        } else if(this.node.type === "radio") {
          if(this.node.checked) {
            setValue(this.node.value);
          }
        } else {
          setValue(this.node.value);
        }
      }
      if(channel.name === "binding") {
        let handler = (e) => {
          if (this.node.form === (e.target || e.srcElement)) {
            domUpdated();
          }
        };
        settings.document.addEventListener("submit", handler, true);
        this.unload.subscribe(function() {
          settings.document.removeEventListener("submit", handler, true);
        });
      } else {
        this.node.addEventListener(channel.name, domUpdated);
      }
    },
    update: function(channel, value) {
      if(this.node.type === "checkbox") {
        return this.node.checked = !!value;
      } else if(this.node.type === "radio") {
        if(value === this.node.value) {
          return this.node.checked = true;
        }
      } else {
        if(value === undefined) {
          value = "";
        }
        return assignUnlessEqual(this.node, "value", value);
      }
    }
  },
  attribute: {
    update: function(channel, value) {
      if(channel.name === 'value') {
        assignUnlessEqual(this.node, "value", value || '');
      } else if(this.type === 'input' && channel.name === 'checked') {
        assignUnlessEqual(this.node, "checked", !!value);
      } else if(channel.name === 'class') {
        this.attributeClasses = value;
        this._updateClass();
      } else if(value === undefined) {
        if(this.node.hasAttribute(channel.name)) {
          this.node.removeAttribute(channel.name);
        }
      } else {
        if(value === 0) {
          value = "0";
        }
        if(this.node.getAttribute(channel.name) !== value) {
          this.node.setAttribute(channel.name, value);
        }
      }
    }
  },
  on: {
    setup: function(channel) {
      if(channel.name === "load" || channel.name === "unload") {
        this[channel.name].subscribe(() => {
          this.context[channel.property](this.node, this.context);
        });
      } else {
        throw new SyntaxError("unkown lifecycle event '" + channel.name + "'");
      }
    }
  },
  property: {
    update: function(channel, value) {
      assignUnlessEqual(this.node, channel.name, value);
    }
  }
};

class Element extends View {
  constructor(context, type, options) {
    super(settings.document.createElement(type))

    this.type = type;
    this.context = context;
    this.classes = options.classes;
    this._updateClass();

    if(options.do) {
      let view = options.do.compile(context);
      view.append(this.node);
      this.children = [view];
    } else {
      this.children = [];
    }

    delete options.classes;
    delete options.do;

    Object.keys(options).forEach((key) => {
      let channel = options[key];
      let action;

      if(!channel.scope && channel.name === "binding") {
        action = Property.binding;
      } else {
        action = Property[channel.scope || "attribute"];
      }

      if(!action) {
        throw SyntaxError("" + channel.scope + " is not a valid scope");
      }

      if(action.setup) {
        action.setup.call(this, channel);
      }

      if(action.update) {
        this.bind(channel, (value) => {
          action.update.call(this, channel, value);
        });
      }
    });


    this.load.trigger();
  }

  _updateClass() {
    let classes = this.classes;
    if(this.attributeClasses) {
      classes = classes.concat(this.attributeClasses);
    }
    if(this.boundClasses && this.boundClasses.length) {
      classes = classes.concat(this.boundClasses.toArray());
    }
    if(classes.length) {
      assignUnlessEqual(this.node, "className", classes.sort().join(' '));
    } else {
      this.node.removeAttribute("class");
    }
  };

  detach() {
    this.unload.trigger();
    super.detach();
  };

}

defineChannel(Element.prototype, "load", { async: false });
defineChannel(Element.prototype, "unload", { async: false });

export default Element;
