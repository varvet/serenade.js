Serenade.registerView 'test', '''
  div[id="foo"]
    h1 "This is a Serenade.js example"
    p
      a[href="http://google.com"] "Go to Google"
    p "Here's some text"
    p
      "This is "
      em "emphasized"
      " text"
'''

element = Serenade.render('test', {}, {})

# Add it to page on load
window.onload = ->
  document.body.appendChild(element)
