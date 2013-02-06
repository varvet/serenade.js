var model = { name: "Jonas" };

// We can pass any object to `render`.
var element = Serenade.render("hello", model);

document.body.appendChild(element);
