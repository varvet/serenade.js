import "coffee-script/register"
import "./spec_helper"
import Channel from "../lib/channel"
import { extend } from "../lib/helpers"
import { helper, attribute, property } from "../lib/decorators"

describe("Serenade.Decorators", function() {
  describe("helper", function() {
    it("maps over channels", function() {
      let channel1 = Channel.of(12);
      let channel2 = Channel.of(34);

      let object = {
        @helper
        add(a, b) {
          return a + b;
        }
      }

      let result = object.add(channel1, channel2);

      expect(result.value).to.equal(46)
      expect(() => channel1.emit(20)).to.emit(result, { with: 54 });
      expect(() => channel2.emit(13)).to.emit(result, { with: 33 });
    });
  });

  describe("attribute", function() {
    it("defines attributes on the class", function() {
      @attribute("first", "last")
      class Person {
        constructor({ first, last }) {
          this.first = first;
          this.last = last;
        }
      }

      let jonas = new Person({ first: "Jonas", last: "Nicklas" })

      expect(jonas["@first"].value).to.equal("Jonas")
      expect(jonas["@last"].value).to.equal("Nicklas")
    });

    it("can pass options", function() {
      @attribute("first", "last", { as(val) { return val.toUpperCase() } })
      class Person {
        constructor({ first, last }) {
          this.first = first;
          this.last = last;
        }
      }

      let jonas = new Person({ first: "Jonas", last: "Nicklas" })

      expect(jonas["@first"].value).to.equal("JONAS")
      expect(jonas["@last"].value).to.equal("NICKLAS")
    });
  });

  describe("property", function() {
    it("defines a property on the class", function() {
      @attribute("first", "last")
      class Person {
        @property({ dependsOn: ["first", "last"] })
        name(first, last) {
          return [first, last].join(" ");
        }

        constructor({ first, last }) {
          this.first = first;
          this.last = last;
        }
      }

      let jonas = new Person({ first: "Jonas", last: "Nicklas" })

      expect(jonas.name).to.equal("Jonas Nicklas")
    });
  });
});
