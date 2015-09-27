import { merge } from "../helpers"
import AttributeChannel from "../channel/attribute_channel"
import AssociationCollection from "../association_collection"
import Collection from "../collection"

export default function(name, options) {
  options = merge({ channelName: "@" + name }, options);

  let attributeOptions = merge(options, {
    channel: function(channelOptions) {
      let collection = new AssociationCollection(this, options, []);
      return new AttributeChannel(this, channelOptions, collection).collection();
    },
    set: function(value) {
      this[options.channelName].value.update(value);
    }
  });

  delete attributeOptions.as;

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
