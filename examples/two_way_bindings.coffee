Serenade.view 'form', '''
  form
    h3 "Fill in stuff here"
    p
      label
        "Title"
        input[type="text" binding:keyup=@title]
    p
      label
        input[type="checkbox" binding:change=@active]
        " Active"
    h4 "Length"
    p
      label
        input[type="radio" name="length" value="Short" binding:change=@length]
        " Short"
    p
      label
        input[type="radio" name="length" value="Long" binding:change=@length]
        " Long"
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
    p "Length: " @length
    p "Body: " @body
'''

class Post extends Serenade.Model
  @property 'title'
  @property 'active', format: (active) -> if active then "yes" else "no"
  @property 'body'
  @property 'length'

window.aPost = new Post()

window.onload = ->
  document.body.appendChild Serenade.render('form', aPost)
  document.body.appendChild document.createElement("hr")
  document.body.appendChild Serenade.render('result', aPost)
