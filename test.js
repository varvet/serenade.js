let Channel = require("./lib/channel");

function attachChannel(object, name, constructor) {
  let channelName = "~" + name;
  let privateChannelName = "~~" + name;

  Object.defineProperty(object, channelName, {
    get: function() {
      if(!this.hasOwnProperty(privateChannelName)) {
        Object.defineProperty(this, privateChannelName, {
          value: constructor.call(this),
          configurable: true,
        });
      }
      return this[privateChannelName];
    },
    configurable: true
  })
}

let properties = (...properties) => {
  return (klass) => {
    properties.forEach((property) => {
      let channelName = "~" + property;

      attachChannel(klass.prototype, property, () => new Channel());

      Object.defineProperty(klass.prototype, property, {
        get: function() { return this[channelName].value },
        set: function(value) { this[channelName].emit(value) },
        enumerable: true,
        configurable: true
      })
    });
  }
}

let dependsOn = (...dependencies) => {
  return (object, name, descriptor) => {
    let getter = descriptor.get;
    if(!getter) {
      throw new Error("dependsOn decorator must be applied to a property declaration with a getter")
    }

    attachChannel(object, name, function() {
      return Channel.all(dependencies.map((d) => this["~" + d]))
    });

    descriptor.get = function() {
      let args = dependencies.map((d) => this[d]);
      let value = getter(...args);

      return value;
    }
    return descriptor;
  }
}


@attributes("firstName", "lastName")
class Person {
  @property("firstName", "lastName")
  get name(firstName, lastName) {
    return [firstName, lastName].join(" ");
  }
}

let person = new Person();

person.firstName = "John";
person.lastName = "Doe";

console.log(person.name);

person["~name"].subscribe((x) => console.log("name updated", x))

person.firstName = "Harry"
person.lastName = "Kane"

