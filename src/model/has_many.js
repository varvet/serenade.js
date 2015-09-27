import { merge } from "../helpers"
import AssociationCollection from "../association_collection"
import Collection from "../collection"

export default function(name, options) {
  if(!options) options = {};

  let channelName = "@" + name;

  let attributeOptions = merge(options, {
    changed: true,
    get: function() {
      if(!this[channelName]) {
        this[channelName] = new AssociationCollection(this, options, []);
      }
      return this[channelName].collection().value;
    },
    set: function(value) {
      this[channelName].value.update(value);
    }
  });

  this.attribute(name, attributeOptions);
  this.property(name + 'Ids', {
    get: function(collection) {
      return collection.map((item) => item.id);
    },
    set: function(ids) {
      let objects = ids.map((id) => options.as().find(id));
      this[name].update(objects);
    },
    dependsOn: name,
    serialize: options.serializeIds
  });
  this.property(name + 'Count', {
    get: function(collection) {
      return collection.length;
    },
    dependsOn: name
  });
};
