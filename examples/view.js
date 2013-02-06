// You can register a view for later rendering like this:
//
// Serenade.view("hello", "…template here…");
//
// In this example we do this for you, so you can more easily
// read and edit the views. Now you can render it like this:
var element = Serenade.render("hello");

// And just as before, we get a DOM element and append it:
document.body.appendChild(element);
