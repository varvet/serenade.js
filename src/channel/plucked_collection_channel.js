import Channel from "./channel"
import DerivedChannel from "./derived_channel"

export default class PluckedCollectionChannel extends DerivedChannel {
  constructor(parent, property) {
    super(parent);
    this.property = property;
  }

  _update(values) {
    if(this._oldValues) {
      this._oldValues.forEach((value) => {
        Channel.get(value, this.property).unsubscribe(this.trigger);
      });
    }
    if(values) {
      values.forEach((value) => {
        Channel.get(value, this.property).subscribe(this.trigger);
      });
      this._oldValues = [].map.call(values, (x) => x)
    } else {
      this._oldValues = undefined;
    }
  }

  get value() {
    return this.parent.value.map((value) => {
      return Channel.get(value, this.property).value
    });
  }
}
