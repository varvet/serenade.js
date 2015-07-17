import View from "./view"
import defineEvent from "../event"
import { settings, assignUnlessEqual } from "../helpers"
import Compile from "../compile"
import Collection from "../collection"

const Property = {
  style: {
    update: function(property, value) {
      assignUnlessEqual(this.node.style, property.name, value);
    }
  },
  event: {
    setup: function(property) {
      this.node.addEventListener(property.name, (e) => {
        if(property.arguments[0].preventDefault) {
          e.preventDefault();
        }
        this.context[property.arguments[0].value](this.node, this.context, e);
      });
    }
  },
  class: {
    update: function(property, value) {
      if(value) {
        if(!this.boundClasses) {
          this.boundClasses = new Collection();
        }
        if(!this.boundClasses.includes(property.name)) {
          this.boundClasses.push(property.name);
          this._updateClass();
        }
      } else if(this.boundClasses) {
        let index = this.boundClasses.indexOf(property.name);
        this.boundClasses.delete(property.name);
        this._updateClass();
      }
    }
  },
  binding: {
    setup: function(property) {
      let value = property.arguments[0].value;
      if(this.ast.name !== "input" && this.ast.name !== "textarea" && this.ast.name !== "select") {
        throw SyntaxError("invalid view type " + this.ast.name + " for two way binding");
      }
      if(!value) {
        throw SyntaxError("cannot bind to whole context, please specify an attribute to bind to");
      }
      let domUpdated = () => {
        if(this.node.type === "checkbox") {
          this.context[value] = this.node.checked;
        } else if(this.node.type === "radio") {
          if(this.node.checked) {
            this.context[value] = this.node.value;
          }
        } else {
          this.context[value] = this.node.value;
        }
      }
      if(property.name === "binding") {
        let handler = (e) => {
          if (this.node.form === (e.target || e.srcElement)) {
            domUpdated();
          }
        };
        settings.document.addEventListener("submit", handler, true);
        this.unload.bind(function() {
          settings.document.removeEventListener("submit", handler, true);
        });
      } else {
        this.node.addEventListener(property.name, domUpdated);
      }
    },
    update: function(property, value) {
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
    update: function(property, value) {
      if(property.name === 'value') {
        assignUnlessEqual(this.node, "value", value || '');
      } else if(this.ast.name === 'input' && property.name === 'checked') {
        assignUnlessEqual(this.node, "checked", !!value);
      } else if(property.name === 'class') {
        this.attributeClasses = value;
        this._updateClass();
      } else if(value === void 0) {
        if(this.node.hasAttribute(property.name)) {
          this.node.removeAttribute(property.name);
        }
      } else {
        if(value === 0) {
          value = "0";
        }
        if(this.node.getAttribute(property.name) !== value) {
          this.node.setAttribute(property.name, value);
        }
      }
    }
  },
  on: {
    setup: function(property) {
      if(property.name === "load" || property.name === "unload") {
        this[property.name].bind(function() {
          this.context[property.arguments[0].value](this.node, this.context);
        });
      } else {
        throw new SyntaxError("unkown lifecycle event '" + property.name + "'");
      }
    }
  },
  property: {
    update: function(property, value) {
      assignUnlessEqual(this.node, property.name, value);
    }
  }
};

class Element extends View {
  constructor(ast, context) {
    super(settings.document.createElement(ast.name))

    this.ast = ast;
    this.context = context;

    if (ast.id) {
      this.node.setAttribute('id', ast.id);
    }

    if(ast.classes && ast.classes.length) {
      this.node.setAttribute('class', ast.classes.join(' '));
    }

    ast.children.forEach((child) => {
      let childView = Compile[child.type](child, context);
      childView.append(this.node);
      this.children.push(childView);
    });

    ast.properties.forEach((property) => {
      let action;

      if(!property.scope && property.name === "binding") {
        action = Property.binding;
      } else {
        action = Property[property.scope || "attribute"];
      }

      if(!action) {
        throw SyntaxError("" + property.scope + " is not a valid scope");
      }

      if(action.setup) {
        action.setup.call(this, property);
      }

      let argument = property.arguments[0];

      if(action.update) {
        if(argument.static) {
          action.update.call(this, property, this.context[argument.value]);
        } else if (argument.bound) {
          if (argument.value) {
            this._bindToModel(argument.value, (value) => action.update.call(this, property, value));
          } else {
            action.update.call(this, property, this.context);
          }
        } else {
          action.update.call(this, property, argument.value);
        }
      } else if(argument.bound) {
        throw SyntaxError("properties in scope " + property.scope + " cannot be bound, use: `" + property.scope + ":" + property.name + "=...")
      }
    });
    this.load.trigger();
  }

  _updateClass() {
    let classes = this.ast.classes;
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

defineEvent(Element.prototype, "load", { async: false });
defineEvent(Element.prototype, "unload", { async: false });

Compile.element = function(ast, context) {
  if(settings.views[ast.name]) {
    return settings.views[ast.name](ast, context);
  } else {
    return new Element(ast, context);
  }
};

export default Element;
