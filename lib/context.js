"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _slicedToArray = (function () { function sliceIterator(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"]) _i["return"](); } finally { if (_d) throw _e; } } return _arr; } return function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { return sliceIterator(arr, i); } else { throw new TypeError("Invalid attempt to destructure non-iterable instance"); } }; })();

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _viewsElement = require("./views/element");

var _viewsElement2 = _interopRequireDefault(_viewsElement);

var _viewsText_view = require("./views/text_view");

var _viewsText_view2 = _interopRequireDefault(_viewsText_view);

var _viewsCollection_view = require("./views/collection_view");

var _viewsCollection_view2 = _interopRequireDefault(_viewsCollection_view);

var _channel = require("./channel");

var _channel2 = _interopRequireDefault(_channel);

var context = {
  "if": function _if(channel, options) {
    var _this = this;

    return channel.map(function (value) {
      if (value) {
        return options["do"].render(_this);
      } else if (options["else"]) {
        return options["else"].render(_this);
      }
    });
  },

  unless: function unless(channel, options) {
    var _this2 = this;

    return channel.map(function (value) {
      if (!value) {
        return options["do"].render(_this2);
      }
    });
  },

  "in": function _in(channel, options) {
    return channel.map(function (value) {
      if (value) {
        return options["do"].render(value);
      }
    });
  },

  element: function element(name, options) {
    return new _viewsElement2["default"](this, name, options);
  },

  content: function content(channel) {
    return channel;
  },

  collection: function collection(channel, options) {
    return new _viewsCollection_view2["default"](channel.collection(), options["do"]);
  },

  coalesce: function coalesce() {
    for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    return _channel2["default"].all(args).map(function (args) {
      return args.join(" ");
    });
  },

  join: function join() {
    for (var _len2 = arguments.length, args = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
      args[_key2] = arguments[_key2];
    }

    return _channel2["default"].all(args).map(function (_ref) {
      var _ref2 = _slicedToArray(_ref, 2);

      var elements = _ref2[0];
      var divider = _ref2[1];

      return elements.join(divider);
    });
  },

  toUpperCase: function toUpperCase(channel) {
    return channel.map(function (val) {
      return val.toUpperCase();
    });
  },

  toLowerCase: function toLowerCase(channel) {
    return channel.map(function (val) {
      return val.toLowerCase();
    });
  }
};

["px"].forEach(function (unit) {
  context[unit] = function (channel) {
    return channel.map(function (val) {
      return val + unit;
    });
  };
});

exports["default"] = context;
module.exports = exports["default"];
