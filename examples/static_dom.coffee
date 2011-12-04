Monkey.registerView 'test', '''
  div[id="foo"]
    h1 "This is a Monkey.js example"
    p
      a[href="http://google.com"] "Go to Google"
    p "Here's some text"
    p
      "This is "
      em "emphasized"
      " text"
'''

element = Monkey.render('test', {}, {})

# Add it to page on load
$ -> $('body').append(element)
