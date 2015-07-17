"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _slicedToArray = (function () { function sliceIterator(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"]) _i["return"](); } finally { if (_d) throw _e; } } return _arr; } return function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { return sliceIterator(arr, i); } else { throw new TypeError("Invalid attempt to destructure non-iterable instance"); } }; })();

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var _property = require("./property");

var _property2 = _interopRequireDefault(_property);

var _event = require("./event");

var _event2 = _interopRequireDefault(_event);

var _helpers = require("./helpers");

var _modelCollection = require("./model/collection");

var _modelCollection2 = _interopRequireDefault(_modelCollection);

var _modelBelongs_to = require("./model/belongs_to");

var _modelBelongs_to2 = _interopRequireDefault(_modelBelongs_to);

var _modelDelegate = require("./model/delegate");

var _modelDelegate2 = _interopRequireDefault(_modelDelegate);

var _modelHas_many = require("./model/has_many");

var _modelHas_many2 = _interopRequireDefault(_modelHas_many);

var _modelSelection = require("./model/selection");

var _modelSelection2 = _interopRequireDefault(_modelSelection);

var _cache = require("./cache");

var _cache2 = _interopRequireDefault(_cache);

var idCounter = 1;

var Model = (function () {
  _createClass(Model, null, [{
    key: "find",
    value: function find(id) {
      return _cache2["default"].get(this, id) || new this({ id: id });
    }
  }, {
    key: "extend",
    value: function extend(ctor) {
      var New = (function (_ref) {
        _inherits(New, _ref);

        function New() {
          _classCallCheck(this, New);

          for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
            args[_key] = arguments[_key];
          }

          var value = _get(Object.getPrototypeOf(New.prototype), "constructor", this).apply(this, args);
          if (value) return value;
          if (ctor) {
            ctor.apply(this, args);
          }
        }

        return New;
      })(this);

      ;
      return New;
    }
  }, {
    key: "property",
    value: function property() {
      var _this = this;

      var options = undefined;

      for (var _len2 = arguments.length, names = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
        names[_key2] = arguments[_key2];
      }

      if (typeof names[names.length - 1] !== "string") {
        options = names.pop();
      } else {
        options = {};
      }
      names.forEach(function (name) {
        return (0, _property2["default"])(_this.prototype, name, options);
      });
    }
  }, {
    key: "event",
    value: function event(name, options) {
      (0, _event2["default"])(this.prototype, name, options);
    }
  }, {
    key: "uniqueId",
    value: function uniqueId() {
      if (!(this._uniqueId && this._uniqueGen === this)) {
        this._uniqueId = idCounter += 1;
        this._uniqueGen = this;
      }
      return this._uniqueId;
    }
  }]);

  function Model(attributes) {
    _classCallCheck(this, Model);

    if (this.constructor.identityMap && attributes && attributes.id) {
      var fromCache = _cache2["default"].get(this.constructor, attributes.id);
      if (fromCache) {
        Model.prototype.set.call(fromCache, attributes);
        return fromCache;
      } else {
        _cache2["default"].set(this.constructor, attributes.id, this);
      }
    }
    for (var _name in attributes) {
      if (!attributes.hasOwnProperty(_name)) continue;
      var value = attributes[_name];
      var property = this[_name + "_property"];
      if (property) {
        property.initialize(value);
      } else {
        this[_name] = value;
      }
    }
  }

  _createClass(Model, [{
    key: "set",
    value: function set(attributes) {
      for (var _name2 in attributes) {
        if (!attributes.hasOwnProperty(_name2)) continue;
        this[_name2] = attributes[_name2];
      }
    }
  }, {
    key: "save",
    value: function save() {
      this.saved.trigger();
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      var _this2 = this;

      var serialized = {};
      this._s.properties.forEach(function (property) {
        if (typeof property.serialize === "string") {
          serialized[property.serialize] = (0, _helpers.serializeObject)(_this2[property.name]);
        } else if (typeof property.serialize === "function") {
          var _property$serialize$call = property.serialize.call(_this2);

          var _property$serialize$call2 = _slicedToArray(_property$serialize$call, 2);

          var key = _property$serialize$call2[0];
          var value = _property$serialize$call2[1];

          serialized[key] = (0, _helpers.serializeObject)(value);
        } else if (property.serialize) {
          serialized[property.name] = (0, _helpers.serializeObject)(_this2[property.name]);
        }
      });
      return serialized;
    }
  }, {
    key: "toString",
    value: function toString() {
      return JSON.stringify(this.toJSON());
    }
  }]);

  return Model;
})();

["property", "event", "uniqueId", "extend", "find"].forEach(function (prop) {
  Object.defineProperty(Model, prop, {
    enumerable: true,
    configurable: true,
    writable: true,
    value: Model[prop]
  });
});

Model.property("id", {
  serialize: true,
  set: function set(val) {
    _cache2["default"].unset(this.constructor, this.id);
    _cache2["default"].set(this.constructor, val, this);
    this._s.val_id = val;
  },
  get: function get() {
    return this._s.val_id;
  }
});

Model.event("saved");

Model.event("changed", {
  optimize: function optimize(queue) {
    var result = {};
    queue.forEach(function (item) {
      return extend(result, item[0]);
    });
    return [result];
  }
});

Model.identityMap = true;
Model.collection = _modelCollection2["default"];
Model.belongsTo = _modelBelongs_to2["default"];
Model.delegate = _modelDelegate2["default"];
Model.hasMany = _modelHas_many2["default"];
Model.selection = _modelSelection2["default"];

exports["default"] = Model;
module.exports = exports["default"];
