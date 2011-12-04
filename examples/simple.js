Monkey.registerView('test', 'div[id="foo"] "Hello World!"');

element = Monkey.render('test', {}, {});

// Add it to page on load
$(function() {
  $('body').append(element);
});
