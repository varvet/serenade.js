import View from "./view"
import { assignUnlessEqual } from "../helpers"

class TextView extends View {
  constructor(value) {
    super(Serenade.document.createTextNode(""));
    this.update(value);
  }

  update(value) {
    if (value === 0) {
      value = "0";
    }
    assignUnlessEqual(this.node, "nodeValue", value || "");
  }
}

export default TextView;
