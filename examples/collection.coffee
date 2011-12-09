Monkey.registerView 'post', '''
  div[id="monkey"]
    h1 title
    p body
    h3 "Comments (" commentCount ")"
    form[submit=postComment]
      p
        textarea[change=commentEdited]
      p
        input[type="submit" value="Post"]
    ul
      - collection comments
        - view comment
'''

Monkey.registerView 'comment', '''
  li
    p body
    p
      a[click=highlight href="#"] "Highlight"
'''

class Post extends Monkey.Model
  @property 'title'
  @property 'body'
  @property 'commentCount', dependsOn: 'comments', get: -> @comments.length
  @collection 'comments'

class Comment extends Monkey.Model
  @property 'body'

class PostController
  postComment: (event) ->
    @model.comments.push(@newComment)
    event.preventDefault()

  commentEdited: (event) ->
    @newComment = { body: event.target.value }

class CommentController
  highlight: ->
    @view.style.backgroundColor = 'red'

Monkey.registerController 'post', PostController
Monkey.registerController 'comment', CommentController

window.aPost = new Post()

aPost.set
  title: 'Monkey.js released!'
  body: 'New contender in the JS framework wars!'
  comments: [{body: 'This is cool'}, {body: 'I hate it'}]

window.onload = ->
  document.body.appendChild Monkey.render('post', aPost)
