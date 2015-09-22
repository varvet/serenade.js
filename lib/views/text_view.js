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

var _settings$assignUnlessEqual = require("../helpers");

var TextView = (function (_View) {
  function TextView(value) {
    _classCallCheck(this, TextView);

    _get(Object.getPrototypeOf(TextView.prototype), "constructor", this).call(this, _settings$assignUnlessEqual.settings.document.createTextNode(""));
    this.update(value);
  }

  _inherits(TextView, _View);

  _createClass(TextView, [{
    key: "update",
    value: function update(value) {
      if (value === 0) {
        value = "0";
      }
      _settings$assignUnlessEqual.assignUnlessEqual(this.node, "nodeValue", value || "");
    }
  }]);

  return TextView;
})(_View3["default"]);

exports["default"] = TextView;
module.exports = exports["default"];
