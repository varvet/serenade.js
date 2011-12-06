Monkey.registerView 'post', '''
  div[id="monkey"]
    h1 title
    p body
    h3 "Comments"
    ul
      - collection comments
        - view comment
'''

Monkey.registerView 'comment', '''
  li
    p body
    p
      a[click=highlight]
'''

class Post extends Monkey.Model
  @property 'title'
  @property 'body'
  @collection 'comments'

class Comment extends Monkey.Model
  @property 'body'

class PostController

class CommentController
  highlight: ->
    @view.style.backgroundColor = 'red'

Monkey.registerController 'post', PostController
Monkey.registerController 'comment', CommentController

window.aPost = new Post()

aPost.comments.update([{body: 'test'}, {body: 'another'}])

window.onload = ->
  view = Monkey.render('post', aPost)
  sandbox = document.body.appendChild(view)
