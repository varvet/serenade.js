"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var _view = require("./view");

var _view2 = _interopRequireDefault(_view);

var _event = require("../event");

var _event2 = _interopRequireDefault(_event);

var _helpers = require("../helpers");

var _compile = require("../compile");

var _compile2 = _interopRequireDefault(_compile);

var _collection = require("../collection");

var _collection2 = _interopRequireDefault(_collection);

var Property = {
  style: {
    update: function update(property, value) {
      (0, _helpers.assignUnlessEqual)(this.node.style, property.name, (0, _helpers.format)(this.context, property.arguments[0].value, value));
    }
  },
  event: {
    setup: function setup(property) {
      var _this = this;

      this.node.addEventListener(property.name, function (e) {
        if (property.arguments[0].preventDefault) {
          e.preventDefault();
        }
        _this.context[property.arguments[0].value](_this.node, _this.context, e);
      });
    }
  },
  "class": {
    update: function update(property, value) {
      if (value) {
        if (!this.boundClasses) {
          this.boundClasses = new _collection2["default"]();
        }
        if (!this.boundClasses.includes(property.name)) {
          this.boundClasses.push(property.name);
          this._updateClass();
        }
      } else if (this.boundClasses) {
        var index = this.boundClasses.indexOf(property.name);
        this.boundClasses["delete"](property.name);
        this._updateClass();
      }
    }
  },
  binding: {
    setup: function setup(property) {
      var _this2 = this;

      var value = property.arguments[0].value;
      if (this.ast.name !== "input" && this.ast.name !== "textarea" && this.ast.name !== "select") {
        throw SyntaxError("invalid view type " + this.ast.name + " for two way binding");
      }
      if (!value) {
        throw SyntaxError("cannot bind to whole context, please specify an attribute to bind to");
      }
      var domUpdated = function domUpdated() {
        if (_this2.node.type === "checkbox") {
          _this2.context[value] = _this2.node.checked;
        } else if (_this2.node.type === "radio") {
          if (_this2.node.checked) {
            _this2.context[value] = _this2.node.value;
          }
        } else {
          _this2.context[value] = _this2.node.value;
        }
      };
      if (property.name === "binding") {
        (function () {
          var handler = function handler(e) {
            if (_this2.node.form === (e.target || e.srcElement)) {
              domUpdated();
            }
          };
          _helpers.settings.document.addEventListener("submit", handler, true);
          _this2.unload.bind(function () {
            _helpers.settings.document.removeEventListener("submit", handler, true);
          });
        })();
      } else {
        this.node.addEventListener(property.name, domUpdated);
      }
    },
    update: function update(property, value) {
      if (this.node.type === "checkbox") {
        return this.node.checked = !!value;
      } else if (this.node.type === "radio") {
        if (value === this.node.value) {
          return this.node.checked = true;
        }
      } else {
        if (value === undefined) {
          value = "";
        }
        return (0, _helpers.assignUnlessEqual)(this.node, "value", value);
      }
    }
  },
  attribute: {
    update: function update(property, value) {
      value = (0, _helpers.format)(this.context, property.arguments[0].value, value);
      if (property.name === 'value') {
        (0, _helpers.assignUnlessEqual)(this.node, "value", value || '');
      } else if (this.ast.name === 'input' && property.name === 'checked') {
        (0, _helpers.assignUnlessEqual)(this.node, "checked", !!value);
      } else if (property.name === 'class') {
        this.attributeClasses = value;
        this._updateClass();
      } else if (value === undefined) {
        if (this.node.hasAttribute(property.name)) {
          this.node.removeAttribute(property.name);
        }
      } else {
        if (value === 0) {
          value = "0";
        }
        if (this.node.getAttribute(property.name) !== value) {
          this.node.setAttribute(property.name, value);
        }
      }
    }
  },
  on: {
    setup: function setup(property) {
      if (property.name === "load" || property.name === "unload") {
        this[property.name].bind(function () {
          this.context[property.arguments[0].value](this.node, this.context);
        });
      } else {
        throw new SyntaxError("unkown lifecycle event '" + property.name + "'");
      }
    }
  },
  property: {
    update: function update(property, value) {
      (0, _helpers.assignUnlessEqual)(this.node, property.name, value);
    }
  }
};

var Element = (function (_View) {
  _inherits(Element, _View);

  function Element(ast, context) {
    var _this3 = this;

    _classCallCheck(this, Element);

    _get(Object.getPrototypeOf(Element.prototype), "constructor", this).call(this, _helpers.settings.document.createElement(ast.name));

    this.ast = ast;
    this.context = context;

    if (ast.id) {
      this.node.setAttribute('id', ast.id);
    }

    if (ast.classes && ast.classes.length) {
      this.node.setAttribute('class', ast.classes.join(' '));
    }

    ast.children.forEach(function (child) {
      var childView = _compile2["default"][child.type](child, context);
      childView.append(_this3.node);
      _this3.children.push(childView);
    });

    ast.properties.forEach(function (property) {
      var action = undefined;

      if (!property.scope && property.name === "binding") {
        action = Property.binding;
      } else {
        action = Property[property.scope || "attribute"];
      }

      if (!action) {
        throw SyntaxError("" + property.scope + " is not a valid scope");
      }

      if (action.setup) {
        action.setup.call(_this3, property);
      }

      var argument = property.arguments[0];

      if (action.update) {
        if (argument["static"]) {
          action.update.call(_this3, property, _this3.context[argument.value]);
        } else if (argument.bound) {
          if (argument.value) {
            _this3._bindToModel(argument.value, function (value) {
              return action.update.call(_this3, property, value);
            });
          } else {
            action.update.call(_this3, property, _this3.context);
          }
        } else {
          action.update.call(_this3, property, argument.value);
        }
      } else if (argument.bound) {
        throw SyntaxError("properties in scope " + property.scope + " cannot be bound, use: `" + property.scope + ":" + property.name + "=...");
      }
    });
    this.load.trigger();
  }

  _createClass(Element, [{
    key: "_updateClass",
    value: function _updateClass() {
      var classes = this.ast.classes;
      if (this.attributeClasses) {
        classes = classes.concat(this.attributeClasses);
      }
      if (this.boundClasses && this.boundClasses.length) {
        classes = classes.concat(this.boundClasses.toArray());
      }
      if (classes.length) {
        (0, _helpers.assignUnlessEqual)(this.node, "className", classes.sort().join(' '));
      } else {
        this.node.removeAttribute("class");
      }
    }
  }, {
    key: "detach",
    value: function detach() {
      this.unload.trigger();
      _get(Object.getPrototypeOf(Element.prototype), "detach", this).call(this);
    }
  }]);

  return Element;
})(_view2["default"]);

(0, _event2["default"])(Element.prototype, "load", { async: false });
(0, _event2["default"])(Element.prototype, "unload", { async: false });

_compile2["default"].element = function (ast, context) {
  if (_helpers.settings.views[ast.name]) {
    return _helpers.settings.views[ast.name](ast, context);
  } else {
    return new Element(ast, context);
  }
};

exports["default"] = Element;
module.exports = exports["default"];
