import { merge } from "../helpers"
import Collection from "../collection"
import AttributeChannel from "../channel/attribute_channel"

export default function(name, options) {
  options = merge({ channelName: "@" + name }, options);

  let attributeOptions = merge(options, {
    channel: function(channelOptions) {
      let collection = new Collection();
      return new AttributeChannel(this, channelOptions, collection).collection();
    },
    set: function(value) {
      this[options.channelName].value.update(value);
    }
  });

  this.attribute(name, attributeOptions);
  this.property(name + 'Count', {
    get: function(collection) {
      return collection.length;
    },
    dependsOn: name
  });
};
