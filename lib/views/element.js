"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(object, property, receiver) { var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

var _inherits = function (subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; };

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _View2 = require("./view");

var _View3 = _interopRequireDefault(_View2);

var _defineChannel = require("../property");

var _settings$assignUnlessEqual$format = require("../helpers");

var _Compile = require("../compile");

var _Compile2 = _interopRequireDefault(_Compile);

var _Collection = require("../collection");

var _Collection2 = _interopRequireDefault(_Collection);

var _Channel = require("../channel");

var _Channel2 = _interopRequireDefault(_Channel);

var Property = {
  style: {
    update: function update(property, value) {
      _settings$assignUnlessEqual$format.assignUnlessEqual(this.node.style, property.name, _settings$assignUnlessEqual$format.format(this.context, property.arguments[0].value, value));
    }
  },
  event: {
    setup: function setup(property) {
      var _this = this;

      this.node.addEventListener(property.name, function (e) {
        if (property.preventDefault) {
          e.preventDefault();
        }
        _this.context[property.value](_this.node, _this.context, e);
      });
    }
  },
  "class": {
    update: function update(property, value) {
      if (value) {
        if (!this.boundClasses) {
          this.boundClasses = new _Collection2["default"]();
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

      var value = property.value;
      if (this.ast.name !== "input" && this.ast.name !== "textarea" && this.ast.name !== "select") {
        throw SyntaxError("invalid view type " + this.ast.name + " for two way binding");
      }
      if (!value) {
        throw SyntaxError("cannot bind to whole context, please specify an attribute to bind to");
      }
      var setValue = function setValue(newValue) {
        var currentValue = _this2.context[value];
        if (currentValue && currentValue.isChannel) {
          currentValue.emit(newValue);
        } else {
          _this2.context[value] = newValue;
        }
      };
      var domUpdated = function domUpdated() {
        if (_this2.node.type === "checkbox") {
          setValue(_this2.node.checked);
        } else if (_this2.node.type === "radio") {
          if (_this2.node.checked) {
            setValue(_this2.node.value);
          }
        } else {
          setValue(_this2.node.value);
        }
      };
      if (property.name === "binding") {
        (function () {
          var handler = function handler(e) {
            if (_this2.node.form === (e.target || e.srcElement)) {
              domUpdated();
            }
          };
          _settings$assignUnlessEqual$format.settings.document.addEventListener("submit", handler, true);
          _this2.unload.subscribe(function () {
            _settings$assignUnlessEqual$format.settings.document.removeEventListener("submit", handler, true);
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
        return _settings$assignUnlessEqual$format.assignUnlessEqual(this.node, "value", value);
      }
    }
  },
  attribute: {
    update: function update(property, value) {
      if (property.name === "value") {
        _settings$assignUnlessEqual$format.assignUnlessEqual(this.node, "value", value || "");
      } else if (this.ast.name === "input" && property.name === "checked") {
        _settings$assignUnlessEqual$format.assignUnlessEqual(this.node, "checked", !!value);
      } else if (property.name === "class") {
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
          this.node.setAttribute(property.name, _settings$assignUnlessEqual$format.format(this.context, property.arguments[0].value, value));
        }
      }
    }
  },
  on: {
    setup: function setup(property) {
      var _this3 = this;

      if (property.name === "load" || property.name === "unload") {
        this[property.name].subscribe(function () {
          _this3.context[property.value](_this3.node, _this3.context);
        });
      } else {
        throw new SyntaxError("unkown lifecycle event '" + property.name + "'");
      }
    }
  },
  property: {
    update: function update(property, value) {
      _settings$assignUnlessEqual$format.assignUnlessEqual(this.node, property.name, value);
    }
  }
};

var Element = (function (_View) {
  function Element(ast, context) {
    var _this4 = this;

    _classCallCheck(this, Element);

    _get(Object.getPrototypeOf(Element.prototype), "constructor", this).call(this, _settings$assignUnlessEqual$format.settings.document.createElement(ast.name));

    this.ast = ast;
    this.context = context;

    if (ast.id) {
      this.node.setAttribute("id", ast.id);
    }

    if (ast.classes && ast.classes.length) {
      this.node.setAttribute("class", ast.classes.join(" "));
    }

    ast.children.forEach(function (child) {
      var childView = _Compile2["default"][child.type](child, context);
      childView.append(_this4.node);
      _this4.children.push(childView);
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

      var channel = _Compile2["default"].parameter(property, context);

      if (action.setup) {
        action.setup.call(_this4, property);
      }

      if (action.update) {
        _this4._bind(channel, function (value) {
          action.update.call(_this4, property, value);
        });
      }
    });
    this.load.trigger();
  }

  _inherits(Element, _View);

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
        _settings$assignUnlessEqual$format.assignUnlessEqual(this.node, "className", classes.sort().join(" "));
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
})(_View3["default"]);

_defineChannel.defineChannel(Element.prototype, "load", { async: false });
_defineChannel.defineChannel(Element.prototype, "unload", { async: false });

_Compile2["default"].element = function (ast, context) {
  if (_settings$assignUnlessEqual$format.settings.views[ast.name]) {
    return _settings$assignUnlessEqual$format.settings.views[ast.name](ast, context);
  } else {
    return new Element(ast, context);
  }
};

exports["default"] = Element;
module.exports = exports["default"];
