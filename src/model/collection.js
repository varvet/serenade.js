import { merge } from "../helpers"
import Collection from "../collection"

export default function(name, options) {
  if(!options) options = {};

  let propOptions = merge(options, {
    changed: true,
    get: function() {
      let valueName = "_" + name;
      if(!this[valueName]) {
        this[valueName] = new Collection([]);
        this[valueName].change.bind(this[name + "_property"].trigger);
      }
      return this[valueName];
    },
    set: function(value) {
      this[name].update(value);
    }
  });

  this.property(name, propOptions);
  this.property(name + 'Count', {
    get: function() {
      return this[name].length;
    },
    dependsOn: name
  });
};
