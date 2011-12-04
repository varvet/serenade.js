Monkey.registerView 'test', '''
  div[id="hello-world"]
    h1 name
    p
      a[click=showAlert href="#"] "Show the alert"
'''

$ ->
  controller = { showAlert: -> alert('Alert!!!') }
  model = { name: 'Jonas' }
  result = Monkey.render('test', model, controller)

  $('body').append(result)
