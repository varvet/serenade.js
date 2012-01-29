Serenade.registerView 'post', '''
  div[id="serenade"]
    h1 @title
    p @body
    h3 "Comments"
    ul
      - collection @comments
        li @body
'''

post =
  title: 'Serenade.js released'
  body: 'New awesome MVC JavaScript framework'
  comments: [{ body: 'Cool!' }, { body: 'Good job!' }]

window.onload = ->
  view = Serenade.render('post', post, {})
  sandbox = document.body.appendChild(view)
