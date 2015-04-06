import { merge } from "../helpers"
import AssociationCollection from "../association_collection"
import Collection from "../collection"

export default function(name, options) {
  if(!options) options = {};

  let propOptions = merge(options, {
    changed: true,
    get: function() {
      let valueName = "_" + name;
      if(!this[valueName]) {
        this[valueName] = new AssociationCollection(this, options, []);
        this[valueName].change.bind(this[name + "_property"].trigger);
      }
      return this[valueName];
    },
    set: function(value) {
      this[name].update(value);
    }
  });

  this.property(name, propOptions);
  this.property(name + 'Ids', {
    get: function() {
      return new Collection(this[name]).map((item) => item.id);
    },
    set: function(ids) {
      let objects = ids.map((id) => options.as().find(id));
      this[name].update(objects);
    },
    dependsOn: name,
    serialize: options.serializeIds
  });
  this.property(name + 'Count', {
    get: function() {
      return this[name].length;
    },
    dependsOn: name
  });
};
