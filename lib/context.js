"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _createDecoratedObject(descriptors) { var target = {}; for (var i = 0; i < descriptors.length; i++) { var descriptor = descriptors[i]; var decorators = descriptor.decorators; var key = descriptor.key; delete descriptor.key; delete descriptor.decorators; descriptor.enumerable = true; descriptor.configurable = true; if ("value" in descriptor || descriptor.initializer) descriptor.writable = true; if (decorators) { for (var f = 0; f < decorators.length; f++) { var decorator = decorators[f]; if (typeof decorator === "function") { descriptor = decorator(target, key, descriptor) || descriptor; } else { throw new TypeError("The decorator for method " + descriptor.key + " is of the invalid type " + typeof decorator); } } } if (descriptor.initializer) { descriptor.value = descriptor.initializer.call(target); } Object.defineProperty(target, key, descriptor); } return target; }

var _viewsElement = require("./views/element");

var _viewsElement2 = _interopRequireDefault(_viewsElement);

var _viewsCollection_view = require("./views/collection_view");

var _viewsCollection_view2 = _interopRequireDefault(_viewsCollection_view);

var _decorators = require("./decorators");

var context = _createDecoratedObject([{
  key: "__element",
  value: function __element(name, options) {
    return new _viewsElement2["default"](this, name, options);
  }
}, {
  key: "__content",
  value: function __content(channel) {
    return channel;
  }
}, {
  key: "if",
  decorators: [_decorators.helper],
  value: function _if(value, options) {
    if (value) {
      return options["do"].render(this);
    } else if (options["else"]) {
      return options["else"].render(this);
    }
  }
}, {
  key: "unless",
  decorators: [_decorators.helper],
  value: function unless(value, options) {
    if (!value) {
      return options["do"].render(this);
    }
  }
}, {
  key: "in",
  value: function _in(channel, options) {
    return channel.map(function (value) {
      if (value) {
        return options["do"].render(value);
      }
    });
  }
}, {
  key: "collection",
  value: function collection(channel, options) {
    return new _viewsCollection_view2["default"](channel.collection(), options["do"]);
  }
}, {
  key: "coalesce",
  decorators: [_decorators.helper],
  value: function coalesce() {
    for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    return args.join(" ");
  }
}, {
  key: "join",
  decorators: [_decorators.helper],
  value: function join(elements, divider) {
    return elements.join(divider);
  }
}, {
  key: "toUpperCase",
  decorators: [_decorators.helper],
  value: function toUpperCase(value) {
    return value.toUpperCase();
  }
}, {
  key: "toLowerCase",
  decorators: [_decorators.helper],
  value: function toLowerCase(value) {
    return value.toLowerCase();
  }
}, {
  key: "url",
  decorators: [_decorators.helper],
  value: function url(value) {
    return "url(" + value + ")";
  }
}, {
  key: "percent",
  decorators: [_decorators.helper],
  value: function percent(value) {
    return value * 100 + "%";
  }
}, {
  key: "debug",
  decorators: [_decorators.helper],
  value: function debug() {
    for (var _len2 = arguments.length, args = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
      args[_key2] = arguments[_key2];
    }

    console.log.apply(console, ["[SERENADE DEBUG]", this].concat(args));
  }
}]);

"em,ex,px,cm,mm,pt,pc,ch,rem,vh,vw,vm,vmin,vmax,deg,rad,grad,turn,ms,s".split(",").forEach(function (unit) {
  context[unit] = function (channel) {
    return channel.map(function (val) {
      return val + unit;
    });
  };
});

exports["default"] = context;
module.exports = exports["default"];
