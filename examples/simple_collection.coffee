Monkey.registerView 'post', '''
  div[id="monkey"]
    h1 title
    p body
    h3 "Comments"
    ul
      - collection comments
        li body
'''

post =
  title: 'Monkey.js released'
  body: 'New awesome MVC JavaScript framework'
  comments: [{ body: 'Cool!' }, { body: 'Good job!' }]

window.onload = ->
  view = Monkey.render('post', post, {})
  sandbox = document.body.appendChild(view)
