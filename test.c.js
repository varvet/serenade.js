"use strict";

var _toConsumableArray = function (arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i]; return arr2; } else { return Array.from(arr); } };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createDecoratedClass = (function () { function defineProperties(target, descriptors, initializers) { for (var i = 0; i < descriptors.length; i++) { var descriptor = descriptors[i]; var decorators = descriptor.decorators; var key = descriptor.key; delete descriptor.key; delete descriptor.decorators; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor || descriptor.initializer) descriptor.writable = true; if (decorators) { for (var f = 0; f < decorators.length; f++) { var decorator = decorators[f]; if (typeof decorator === "function") { descriptor = decorator(target, key, descriptor) || descriptor; } else { throw new TypeError("The decorator for method " + descriptor.key + " is of the invalid type " + typeof decorator); } } if (descriptor.initializer) { initializers[key] = descriptor; continue; } } Object.defineProperty(target, key, descriptor); } } return function (Constructor, protoProps, staticProps, protoInitializers, staticInitializers) { if (protoProps) defineProperties(Constructor.prototype, protoProps, protoInitializers); if (staticProps) defineProperties(Constructor, staticProps, staticInitializers); return Constructor; }; })();

var Channel = require("./lib/channel");

function attachChannel(object, name, constructor) {
  var channelName = "~" + name;
  var privateChannelName = "~~" + name;

  Object.defineProperty(object, channelName, {
    get: function get() {
      if (!this.hasOwnProperty(privateChannelName)) {
        Object.defineProperty(this, privateChannelName, {
          value: constructor.call(this),
          configurable: true });
      }
      return this[privateChannelName];
    },
    enumerable: true,
    configurable: true
  });
}

var properties = (function (_properties) {
  function properties(_x) {
    return _properties.apply(this, arguments);
  }

  properties.toString = function () {
    return _properties.toString();
  };

  return properties;
})(function () {
  for (var _len = arguments.length, properties = Array(_len), _key = 0; _key < _len; _key++) {
    properties[_key] = arguments[_key];
  }

  return function (klass) {
    properties.forEach(function (property) {
      var channelName = "~" + property;

      attachChannel(klass.prototype, property, function () {
        return new Channel();
      });

      Object.defineProperty(klass.prototype, property, {
        get: function get() {
          return this[channelName].value;
        },
        set: function set(value) {
          this[channelName].emit(value);
        },
        enumerable: true,
        configurable: true
      });
    });
  };
});

var dependsOn = function dependsOn() {
  for (var _len2 = arguments.length, dependencies = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
    dependencies[_key2] = arguments[_key2];
  }

  return function (object, name, descriptor) {
    var getter = descriptor.get;
    if (!getter) {
      throw new Error("dependsOn decorator must be applied to a property declaration with a getter");
    }

    attachChannel(object, name, function () {
      var _this = this;

      return Channel.all(dependencies.map(function (d) {
        return _this["~" + d];
      }));
    });

    descriptor.get = function () {
      var _this2 = this;

      var args = dependencies.map(function (d) {
        return _this2[d];
      });
      var value = getter.apply(undefined, _toConsumableArray(args));

      return value;
    };
    return descriptor;
  };
};

var Person = (function () {
  function Person() {
    _classCallCheck(this, _Person);
  }

  var _Person = Person;

  _createDecoratedClass(_Person, [{
    key: "name",
    decorators: [dependsOn("firstName", "lastName")],
    get: function (firstName, lastName) {
      return [firstName, lastName].join(" ");
    }
  }]);

  Person = properties("firstName", "lastName")(Person) || Person;
  return Person;
})();

var person = new Person();

person.firstName = "John";
person.lastName = "Doe";

console.log(person.name);

person["~name"].subscribe(function (x) {
  return console.log("name updated", x);
});

person.firstName = "Harry";
person.lastName = "Kane";
