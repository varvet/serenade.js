var Color = Serenade.Model.extend()

Color.property("r", "g", "b", { value: 255 })

Color.property("rgb", { get: function() {
  return "rgb(" + this.r + ", " + this.g + ", " + this.b + ")"
}});

document.body.appendChild(Serenade.render("color", new Color()))
