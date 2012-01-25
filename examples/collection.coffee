Serenade.registerView 'post', '''
  div#serenade
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

Serenade.registerView 'comment', '''
  li[style:backgroundColor=color]
    p body
    p
      a[event:click=highlight! href="#"] "Highlight"
      " | "
      a[event:click=remove! href="#"] "Remove"
'''

class Post extends Serenade.Model
  @property 'commentCount', dependsOn: 'comments', get: -> @comments.length
  @hasMany 'comments', as: (-> Comment), serialize: true
  @localStorage: true

class Comment extends Serenade.Model
  @property 'body', serialize: true

class PostController
  postComment: ->
    @model.comments.push(body: @body) if @body
  commentEdited: (event) ->
    @body = (event.target or event.srcElement).value
  removeComment: (comment) ->
    @model.comments.delete(comment)

class CommentController
  highlight: ->
    @model.set('color', 'yellow')
  remove: ->
    @parent.removeComment(@model)

Serenade.registerController 'post', PostController
Serenade.registerController 'comment', CommentController

window.aPost = Post.find(5)
aPost.set
  title: 'Serenade.js released!'
  body: 'New contender in the JS framework wars!'

window.onload = ->
  document.body.appendChild Serenade.render('post', aPost)
