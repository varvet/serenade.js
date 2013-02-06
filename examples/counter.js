// Let's puss it all together!
// Press the `+` button to increment the counter.
var counter = Serenade({ current: 0 });
var controller = {
  increment: function() {
    counter.current += 1;
  }
};
var element = Serenade.render("counter", counter, controller);
document.body.appendChild(element);
