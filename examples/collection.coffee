Monkey.registerView 'post', '''
  div[id="monkey"]
    h1 title
    p body
    h3 "Comments (" commentCount ")"
    ul
      - collection comments
        - view comment
    form[event:submit=postComment!]
      p
        textarea[event:change=commentEdited]
      p
        input[type="submit" value="Post"]
'''

Monkey.registerView 'comment', '''
  li[style:backgroundColor=color]
    p body
    p
      a[event:click=highlight! href="#"] "Highlight"
      " | "
      a[event:click=remove! href="#"] "Remove"
'''

class Post extends Monkey.Model
  @property 'title'
  @property 'body'
  @property 'commentCount', dependsOn: 'comments', get: -> @comments.length
  @collection 'comments'

class Comment extends Monkey.Model
  @property 'body'

class PostController
  postComment: ->
    @model.comments.push(@newComment)

  commentEdited: (event) ->
    @newComment = new Comment(body: event.target.value)

class CommentController
  highlight: ->
    @model.set('color', 'yellow')
  remove: ->
    comments = @parent.model.comments
    comments.delete(comments.indexOf(@model))

Monkey.registerController 'post', PostController
Monkey.registerController 'comment', CommentController

window.aPost = new Post
  title: 'Monkey.js released!'
  body: 'New contender in the JS framework wars!'
  comments: [new Comment(body: 'This is cool'), new Comment(body: 'I hate it')]

window.onload = ->
  document.body.appendChild Monkey.render('post', aPost)
