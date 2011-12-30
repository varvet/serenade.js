Serenade.registerView('test', 'div[id="foo"] "Hello World!"');

element = Serenade.render('test', {}, {});

// Add it to page on load
window.onload = function() {
  document.body.appendChild(element);
};
