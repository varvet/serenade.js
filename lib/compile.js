"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.toView = toView;

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _channel = require("./channel");

var _channel2 = _interopRequireDefault(_channel);

var _viewsDynamic_view = require("./views/dynamic_view");

var _viewsDynamic_view2 = _interopRequireDefault(_viewsDynamic_view);

var _viewsView = require("./views/view");

var _viewsView2 = _interopRequireDefault(_viewsView);

var _viewsText_view = require("./views/text_view");

var _viewsText_view2 = _interopRequireDefault(_viewsText_view);

function toView(object) {
  if (object && object.isView) {
    return object;
  } else if (object && object.isChannel) {
    var _ret = (function () {
      var view = new _viewsDynamic_view2["default"]();
      view.bind(object, function (value) {
        view.replace([].concat(value || []).map(toView));
      });
      return {
        v: view
      };
    })();

    if (typeof _ret === "object") return _ret.v;
  } else if (object && object.nodeType === 1) {
    return new _viewsView2["default"](object);
  } else if (object && object.nodeType === 3) {
    return new _viewsText_view2["default"](object.nodeValue);
  } else {
    return new _viewsText_view2["default"](object);
  }
}

var Compile = {
  parameter: function parameter(ast, context) {
    if (ast.bound) {
      if (ast.value === "this") {
        return _channel2["default"]["static"](context);
      } else {
        var value = context && context[ast.value];
        if (value && value.isChannel) {
          return value;
        } else {
          return _channel2["default"]["static"](value);
        }
      }
    } else {
      return _channel2["default"]["static"](ast.value);
    }
  }
};

exports["default"] = Compile;
