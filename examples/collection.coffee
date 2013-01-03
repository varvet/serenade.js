Serenade.view 'post', '''
  div#serenade
    h1 @title
    p @body
    h3 "Comments (" @commentCount ")"
    ul
      - collection @comments
        - view @comment
    form[event:submit=postComment!]
      p
        textarea[event:change=commentEdited]
      p
        input[type="submit" value="Post"]
'''

Serenade.view 'comment', '''
  li[style:backgroundColor=@color]
    p @body
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
  @property 'color'

class PostController
  constructor: (@post) ->
  postComment: ->
    @post.comments.push(body: @body) if @body
  commentEdited: (post,element) ->
    @body = element.value
  highlight: (comment) ->
    comment.color = 'yellow'
  remove: (comment) ->
    @post.comments.delete(comment)

window.aPost = Post.find(5)
aPost.set
  title: 'Serenade.js released!'
  body: 'New contender in the JS framework wars!'

window.onload = ->
  document.body.appendChild Serenade.render('post', aPost, PostController)
