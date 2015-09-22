"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _slicedToArray = function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"]) _i["return"](); } finally { if (_d) throw _e; } } return _arr; } else { throw new TypeError("Invalid attempt to destructure non-iterable instance"); } };

var _get = function get(object, property, receiver) { var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

var _inherits = function (subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _defineProperty$defineAttribute$defineChannel = require("./property");

var _serializeObject = require("./helpers");

var _collection = require("./model/collection");

var _collection2 = _interopRequireDefault(_collection);

var _belongsTo = require("./model/belongs_to");

var _belongsTo2 = _interopRequireDefault(_belongsTo);

var _delegate = require("./model/delegate");

var _delegate2 = _interopRequireDefault(_delegate);

var _hasMany = require("./model/has_many");

var _hasMany2 = _interopRequireDefault(_hasMany);

var _selection = require("./model/selection");

var _selection2 = _interopRequireDefault(_selection);

var _Cache = require("./cache");

var _Cache2 = _interopRequireDefault(_Cache);

var idCounter = 1;

var Model = (function () {
  function Model(attributes) {
    _classCallCheck(this, Model);

    if (this.constructor.identityMap && attributes && attributes.id) {
      var fromCache = _Cache2["default"].get(this.constructor, attributes.id);
      if (fromCache) {
        Model.prototype.set.call(fromCache, attributes);
        return fromCache;
      } else {
        _Cache2["default"].set(this.constructor, attributes.id, this);
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
      var _this = this;

      var serialized = {};
      this._s.properties.forEach(function (property) {
        if (typeof property.serialize === "string") {
          serialized[property.serialize] = _serializeObject.serializeObject(_this[property.name]);
        } else if (typeof property.serialize === "function") {
          var _property$serialize$call = property.serialize.call(_this);

          var _property$serialize$call2 = _slicedToArray(_property$serialize$call, 2);

          var key = _property$serialize$call2[0];
          var value = _property$serialize$call2[1];

          serialized[key] = _serializeObject.serializeObject(value);
        } else if (property.serialize) {
          serialized[property.name] = _serializeObject.serializeObject(_this[property.name]);
        }
      });
      return serialized;
    }
  }, {
    key: "toString",
    value: function toString() {
      return JSON.stringify(this.toJSON());
    }
  }], [{
    key: "find",
    value: function find(id) {
      return _Cache2["default"].get(this, id) || new this({ id: id });
    }
  }, {
    key: "extend",
    value: function extend(ctor) {
      var New = (function (_ref) {
        function New() {
          for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
            args[_key] = arguments[_key];
          }

          _classCallCheck(this, New);

          var value = _get(Object.getPrototypeOf(New.prototype), "constructor", this).apply(this, args);
          if (value) {
            return value;
          }if (ctor) {
            ctor.apply(this, args);
          }
        }

        _inherits(New, _ref);

        return New;
      })(this);

      ;
      return New;
    }
  }, {
    key: "attribute",
    value: function attribute() {
      var _this2 = this;

      for (var _len2 = arguments.length, names = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
        names[_key2] = arguments[_key2];
      }

      var options = undefined;
      if (typeof names[names.length - 1] !== "string") {
        options = names.pop();
      } else {
        options = {};
      }
      names.forEach(function (name) {
        return _defineProperty$defineAttribute$defineChannel.defineAttribute(_this2.prototype, name, options);
      });
    }
  }, {
    key: "property",
    value: function property() {
      var _this3 = this;

      for (var _len3 = arguments.length, names = Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
        names[_key3] = arguments[_key3];
      }

      var options = undefined;
      if (typeof names[names.length - 1] !== "string") {
        options = names.pop();
      } else {
        options = {};
      }
      names.forEach(function (name) {
        return _defineProperty$defineAttribute$defineChannel.defineProperty(_this3.prototype, name, options);
      });
    }
  }, {
    key: "channel",
    value: function channel(name, options) {
      _defineProperty$defineAttribute$defineChannel.defineChannel(this.prototype, name, options);
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

  return Model;
})();

["property", "attribute", "channel", "uniqueId", "extend", "find"].forEach(function (prop) {
  Object.defineProperty(Model, prop, {
    enumerable: true,
    configurable: true,
    writable: true,
    value: Model[prop]
  });
});

Model.attribute("id", {
  serialize: true,
  set: function set(val) {
    _Cache2["default"].unset(this.constructor, this.id);
    _Cache2["default"].set(this.constructor, val, this);
    val;
  }
});

Model.channel("saved");

Model.channel("changed", {
  optimize: function optimize(queue) {
    var result = {};
    queue.forEach(function (item) {
      return extend(result, item[0]);
    });
    return [result];
  }
});

Model.identityMap = true;
Model.collection = _collection2["default"];
Model.belongsTo = _belongsTo2["default"];
Model.delegate = _delegate2["default"];
Model.hasMany = _hasMany2["default"];
Model.selection = _selection2["default"];

exports["default"] = Model;
module.exports = exports["default"];
