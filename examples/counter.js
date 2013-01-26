var counter = Serenade({ current: 0 });
var controller = {
  increment: function() {
    counter.current += 1;
  },
  decrement: function() {
    counter.current -= 1;
  }
};
var element = Serenade.render("counter", counter, controller);
document.body.appendChild(element);
