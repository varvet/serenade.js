Serenade.view 'form', '''
  form[event:submit=stop!]
    h3 "Fill in stuff here"
    p
      label
        "Title"
        input[type="text" binding:keyup=@title]
    p
      label
        input[type="checkbox" binding:change=@active]
        " Active"
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
        " Category"
        br
        select[binding:change=@category]
          option ""
          option "Cats"
          option "Serenade.js"
          option "World Domination"
    p
      label
        "Body (click Update to see this change)"
        br
        textarea[binding=@body cols="60" rows="8"]
    p
      input[type="submit" value="Update"]
'''

Serenade.view 'result', '''
  div
    h3 "See this change magically"
    p "Title: " @title
    p "Active: " @active
    p "Length: " @length
    p "Category: " @category
    p "Body: " @body
'''

class Post extends Serenade.Model
  @property 'active', format: (active) -> if active then "yes" else "no"

window.onload = ->
  window.aPost = new Post()
  document.body.appendChild Serenade.render('form', aPost, stop: ->)
  document.body.appendChild document.createElement("hr")
  document.body.appendChild Serenade.render('result', aPost)
