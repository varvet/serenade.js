// If your data can change, use the Serenade decorator to
// create an object whose value are changed in the view as
// they change on the model.
var counter = Serenade({ current: 0 });

// If we update the model in our controller, the view will
// change automatically.
var controller = {
  increment: function() {
    counter.current += 1;
  }
};

var element = Serenade.render("counter", counter, controller);
document.body.appendChild(element);
