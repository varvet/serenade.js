"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _viewsDynamic_view = require("./views/dynamic_view");

var _viewsDynamic_view2 = _interopRequireDefault(_viewsDynamic_view);

var _viewsElement = require("./views/element");

var _viewsElement2 = _interopRequireDefault(_viewsElement);

var _viewsText_view = require("./views/text_view");

var _viewsText_view2 = _interopRequireDefault(_viewsText_view);

var _viewsCollection_view = require("./views/collection_view");

var _viewsCollection_view2 = _interopRequireDefault(_viewsCollection_view);

exports["default"] = {
  "if": function _if(channel, options) {
    var _this = this;

    return _viewsDynamic_view2["default"].bind(channel, function (view, value) {
      if (value) {
        view.replace([options["do"].render(_this)]);
      } else if (options["else"]) {
        view.replace([options["else"].render(_this)]);
      } else {
        view.clear();
      }
    });
  },

  element: function element(name, options) {
    return new _viewsElement2["default"](this, name, options);
  },

  content: function content(channel) {
    return _viewsDynamic_view2["default"].bind(channel, function (view, value) {
      if (value && value.isView) {
        view.replace([value]);
      } else {
        view.replace([new _viewsText_view2["default"](value)]);
      }
    });
  },

  collection: function collection(channel, options) {
    return new _viewsCollection_view2["default"](channel.collection(), options["do"]);
  }
};
module.exports = exports["default"];
