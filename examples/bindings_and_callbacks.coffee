Serenade.registerView 'test', '''
  div[id="hello-world"]
    h1 @name
    p
      a[event:click=showAlert href="#"] "Show the alert"
'''

controller = { showAlert: -> alert('Alert!!!') }
model = { name: 'Jonas' }

result = Serenade.render('test', model, controller)

window.onload = ->
  document.body.appendChild(result)
