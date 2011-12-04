(function() {
  var Monkey;
  Monkey = require('./monkey').Monkey;
  Monkey.Element = (function() {
    function Element(name, attributes, children) {
      this.name = name;
      this.attributes = attributes;
      this.children = children;
      this.attributes || (this.attributes = []);
      this.children || (this.children = []);
    }
    return Element;
  })();
  Monkey.Attribute = (function() {
    function Attribute(name, value, bound) {
      this.name = name;
      this.value = value;
      this.bound = bound;
    }
    return Attribute;
  })();
  Monkey.TextNode = (function() {
    function TextNode(value, bound) {
      this.value = value;
      this.bound = bound;
    }
    TextNode.prototype.name = 'text';
    return TextNode;
  })();
}).call(this);
