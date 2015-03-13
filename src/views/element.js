import View from "./view"
import defineEvent from "../event"

var Element,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Element = (function(_super) {
  __extends(Element, _super);

  defineEvent(Element.prototype, "load", {
    async: false
  });

  defineEvent(Element.prototype, "unload", {
    async: false
  });

  function Element(ast, context) {
    var child, childView, _i, _len, _ref, _ref1;
    this.ast = ast;
    this.context = context;
    Element.__super__.constructor.call(this, Serenade.document.createElement(this.ast.name));
    if (this.ast.id) {
      this.node.setAttribute('id', this.ast.id);
    }
    if ((_ref = this.ast.classes) != null ? _ref.length : void 0) {
      this.node.setAttribute('class', this.ast.classes.join(' '));
    }
    _ref1 = this.ast.children;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      child = _ref1[_i];
      childView = Compile[child.type](child, this.context);
      childView.append(this.node);
      this.children.push(childView);
    }
    this.ast.properties.forEach((function(_this) {
      return function(property) {
        var action;
        action = property.scope === "attribute" && property.name === "binding" ? _this.property.binding : _this.property[property.scope];
        if (action) {
          if (action.setup) {
            action.setup.call(_this, property);
          }
          if (action.update) {
            if (property["static"]) {
              return action.update.call(_this, property, _this.context[property.value]);
            } else if (property.bound) {
              if (property.value) {
                return _this._bindToModel(property.value, function(value) {
                  return action.update.call(_this, property, value);
                });
              } else {
                return action.update.call(_this, property, _this.context);
              }
            } else {
              return action.update.call(_this, property, property.value);
            }
          } else if (property.bound) {
            throw SyntaxError("properties in scope " + property.scope + " cannot be bound, use: `" + property.scope + ":" + property.name + "=" + property.value + "`");
          }
        } else {
          throw SyntaxError("" + property.scope + " is not a valid scope");
        }
      };
    })(this));
    this.load.trigger();
  }

  Element.prototype._updateClass = function() {
    var classes, _ref;
    classes = this.ast.classes;
    if (this.attributeClasses) {
      classes = classes.concat(this.attributeClasses);
    }
    if ((_ref = this.boundClasses) != null ? _ref.length : void 0) {
      classes = classes.concat(this.boundClasses.toArray());
    }
    classes.sort();
    if (classes.length) {
      return assignUnlessEqual(this.node, "className", classes.join(' '));
    } else {
      return this.node.removeAttribute("class");
    }
  };

  Element.prototype.detach = function() {
    this.unload.trigger();
    return Element.__super__.detach.apply(this, arguments);
  };

  Element.prototype.property = {
    style: {
      update: function(property, value) {
        return assignUnlessEqual(this.node.style, property.name, value);
      }
    },
    event: {
      setup: function(property) {
        return this.node.addEventListener(property.name, (function(_this) {
          return function(e) {
            if (property.preventDefault) {
              e.preventDefault();
            }
            return _this.context[property.value](_this.node, _this.context, e);
          };
        })(this));
      }
    },
    "class": {
      update: function(property, value) {
        var index, _ref;
        if (value) {
          this.boundClasses || (this.boundClasses = new Collection());
          if (!((_ref = this.boundClasses) != null ? _ref.includes(property.name) : void 0)) {
            this.boundClasses.push(property.name);
            return this._updateClass();
          }
        } else if (this.boundClasses) {
          index = this.boundClasses.indexOf(property.name);
          this.boundClasses["delete"](property.name);
          return this._updateClass();
        }
      }
    },
    binding: {
      setup: function(property) {
        var domUpdated, handler, _ref;
        ((_ref = this.ast.name) === "input" || _ref === "textarea" || _ref === "select") || (function() {
          throw SyntaxError("invalid view type " + this.ast.name + " for two way binding");
        }).call(this);
        property.value || (function() {
          throw SyntaxError("cannot bind to whole context, please specify an attribute to bind to");
        })();
        domUpdated = (function(_this) {
          return function() {
            return _this.context[property.value] = _this.node.type === "checkbox" ? _this.node.checked : _this.node.type === "radio" ? _this.node.checked ? _this.node.getAttribute("value") : void 0 : _this.node.value;
          };
        })(this);
        if (property.name === "binding") {
          handler = (function(_this) {
            return function(e) {
              if (_this.node.form === (e.target || e.srcElement)) {
                return domUpdated();
              }
            };
          })(this);
          Serenade.document.addEventListener("submit", handler, true);
          return this.unload.bind(function() {
            return Serenade.document.removeEventListener("submit", handler, true);
          });
        } else {
          return this.node.addEventListener(property.name, domUpdated);
        }
      },
      update: function(property, value) {
        if (this.node.type === "checkbox") {
          return this.node.checked = !!value;
        } else if (this.node.type === "radio") {
          if (value === this.node.getAttribute("value")) {
            return this.node.checked = true;
          }
        } else {
          if (value === void 0) {
            value = "";
          }
          return assignUnlessEqual(this.node, "value", value);
        }
      }
    },
    attribute: {
      update: function(property, value) {
        if (property.name === 'value') {
          return assignUnlessEqual(this.node, "value", value || '');
        } else if (this.ast.name === 'input' && property.name === 'checked') {
          return assignUnlessEqual(this.node, "checked", !!value);
        } else if (property.name === 'class') {
          this.attributeClasses = value;
          return this._updateClass();
        } else if (value === void 0) {
          if (this.node.hasAttribute(property.name)) {
            return this.node.removeAttribute(property.name);
          }
        } else {
          if (value === 0) {
            value = "0";
          }
          if (this.node.getAttribute(property.name) !== value) {
            return this.node.setAttribute(property.name, value);
          }
        }
      }
    },
    on: {
      setup: function(property) {
        var _ref;
        if ((_ref = property.name) === "load" || _ref === "unload") {
          return this[property.name].bind(function() {
            return this.context[property.value](this.node, this.context);
          });
        } else {
          throw new SyntaxError("unkown lifecycle event '" + property.name + "'");
        }
      }
    },
    property: {
      update: function(property, value) {
        return assignUnlessEqual(this.node, property.name, value);
      }
    }
  };

  return Element;

})(View);

export default Element;
