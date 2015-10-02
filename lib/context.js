"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _viewsDynamic_view = require("./views/dynamic_view");

var _viewsDynamic_view2 = _interopRequireDefault(_viewsDynamic_view);

var _viewsElement = require("./views/element");

var _viewsElement2 = _interopRequireDefault(_viewsElement);

var _viewsContent_view = require("./views/content_view");

var _viewsContent_view2 = _interopRequireDefault(_viewsContent_view);

exports["default"] = {
  "if": function _if(channel, options) {
    var _this = this;

    var view = new _viewsDynamic_view2["default"]();
    channel.bind(function (value) {
      if (value) {
        view.replace([options["do"].render(_this)]);
      } else {
        view.clear();
      }
    });
  },

  element: function element(name, options) {
    return new _viewsElement2["default"](this, name, options);
  },

  content: function content(channel) {
    return new _viewsContent_view2["default"](channel);
  }
};
module.exports = exports["default"];
