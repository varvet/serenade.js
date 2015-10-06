"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _viewsElement = require("./views/element");

var _viewsElement2 = _interopRequireDefault(_viewsElement);

var _viewsText_view = require("./views/text_view");

var _viewsText_view2 = _interopRequireDefault(_viewsText_view);

var _viewsCollection_view = require("./views/collection_view");

var _viewsCollection_view2 = _interopRequireDefault(_viewsCollection_view);

var _channel = require("./channel");

var _channel2 = _interopRequireDefault(_channel);

exports["default"] = {
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
    return channel.map(function (value) {
      if (value && value.isView) {
        return value;
      } else {
        return new _viewsText_view2["default"](value);
      }
    });
  },

  collection: function collection(channel, options) {
    return new _viewsCollection_view2["default"](channel.collection(), options["do"]);
  }
};
module.exports = exports["default"];
