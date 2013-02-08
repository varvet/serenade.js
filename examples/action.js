var model = {};
var controller = { greet: function() { alert("Hello!") } };

// Our controller too, is just regular ol' JavaScript.
var element = Serenade.render("greet", model, controller);

document.body.appendChild(element);
