Monkey.registerView('test', 'div[id="foo"] "Hello World!"');

element = Monkey.render('test', {}, {});

// Add it to page on load
window.onload = function() {
  document.body.appendChild(element);
};
