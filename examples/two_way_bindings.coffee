Serenade.view 'form', '''
  form
    h3 "Fill in stuff here"
    p
      label
        "Title"
        input[type="text" binding:keyup=@title]
    p
      label
        "Active"
        input[type="checkbox" binding:change=@active]
    p
      label
        "Body"
        br
        textarea[binding:keyup=@body cols="60" rows="8"]
'''

Serenade.view 'result', '''
  div
    h3 "See this change magically"
    p "Title: " @title
    p "Active: " @active
    p "Body: " @body
'''

class Post extends Serenade.Model
  @property 'title'
  @property 'active', format: (active) -> if active then "yes" else "no"
  @property 'body'

window.aPost = new Post()

window.onload = ->
  document.body.appendChild Serenade.render('form', aPost)
  document.body.appendChild document.createElement("hr")
  document.body.appendChild Serenade.render('result', aPost)
