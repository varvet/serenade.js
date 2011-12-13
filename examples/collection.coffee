Monkey.registerView 'post', '''
  div[id="monkey"]
    h1 title
    p body
    h3 "Comments (" commentCount ")"
    ul
      - collection comments
        - view comment
    form[submit=postComment]
      p
        textarea[change=commentEdited]
      p
        input[type="submit" value="Post"]
'''

Monkey.registerView 'comment', '''
  li[style-backgroundColor=color]
    p body
    p
      a[click=highlight href="#"] "Highlight"
      " | "
      a[click=remove href="#"] "Remove"
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
    @newComment = new Comment(body: event.target.value)

class CommentController
  highlight: (event) ->
    @model.set('color', 'yellow')
    event.preventDefault()
  remove: (event) ->
    comments = @parent.model.comments
    comments.delete(comments.indexOf(@model))
    event.preventDefault()

Monkey.registerController 'post', PostController
Monkey.registerController 'comment', CommentController

window.aPost = new Post
  title: 'Monkey.js released!'
  body: 'New contender in the JS framework wars!'
  comments: [new Comment(body: 'This is cool'), new Comment(body: 'I hate it')]

window.onload = ->
  document.body.appendChild Monkey.render('post', aPost)
