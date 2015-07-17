"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

exports["default"] = Transform;

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var _helpers = require("./helpers");

var Map = (function () {
  function Map(array) {
    var _this = this;

    _classCallCheck(this, Map);

    this.map = {};
    array.forEach(function (element, index) {
      return _this.put(index, element);
    });
  }

  _createClass(Map, [{
    key: "isMember",
    value: function isMember(key) {
      var element = this.map[(0, _helpers.hash)(key)];
      return element && element[0].length > 0;
    }
  }, {
    key: "indexOf",
    value: function indexOf(key) {
      var element = this.map[(0, _helpers.hash)(key)];
      return element && element[0] && element[0][0];
    }
  }, {
    key: "put",
    value: function put(index, key) {
      var h = (0, _helpers.hash)(key);
      var existing = this.map[h];
      if (existing) {
        this.map[h] = [existing[0].concat(index).sort(function (a, b) {
          return a - b;
        }), key];
      } else {
        this.map[h] = [[index], key];
      }
    }
  }, {
    key: "remove",
    value: function remove(key) {
      var element = this.map[(0, _helpers.hash)(key)];
      if (element && element[0]) {
        element[0].shift();
      }
    }
  }]);

  return Map;
})();

function Transform(from, to) {
  if (!from) {
    from = [];
  }
  if (!to) {
    to = [];
  }

  var operations = [];
  to = to.map(function (e) {
    return e;
  });
  var targetMap = new Map(to);
  var cleaned = [];

  from.forEach(function (element) {
    if (targetMap.isMember(element)) {
      cleaned.push(element);
    } else {
      operations.push({ type: "remove", index: cleaned.length });
    }
    targetMap.remove(element);
  });

  var complete = [].concat(cleaned);

  var cleanedMap = new Map(cleaned);

  to.forEach(function (element, index) {
    if (!cleanedMap.isMember(element)) {
      operations.push({ type: "insert", index: index, value: element });
      complete.splice(index, 0, element);
    }
    cleanedMap.remove(element);
  });

  var completeMap = new Map(complete);

  complete.forEach(function (actual, indexActual) {
    var wanted = to[indexActual];
    if (actual !== wanted) {
      var indexWanted = completeMap.indexOf(wanted);
      completeMap.remove(actual);
      completeMap.remove(wanted);
      completeMap.put(indexWanted, actual);
      complete[indexActual] = wanted;
      complete[indexWanted] = actual;
      operations.push({ type: "swap", index: indexActual, "with": indexWanted });
    } else {
      completeMap.remove(actual);
    }
  });

  return operations;
}

;
module.exports = exports["default"];
