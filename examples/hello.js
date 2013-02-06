// First we render a Serenade view
var element = Serenade.view('h1 "Hello world"').render();

// We get back a regular DOM element, so we just append it
document.body.appendChild(element);
