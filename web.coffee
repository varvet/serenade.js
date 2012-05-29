express = require 'express'
fs = require 'fs'
path = require 'path'
CoffeeScript = require 'coffee-script'

app = express.createServer(express.logger())

app.register '.serenade', require('./src/serenade')

app.get '/', (request, response) ->
  examples = fs.readdirSync('examples').map (dir) -> { name: dir, url: "/#{dir}" }
  response.render('index.serenade', model: { examples }, layout: false)

app.get '/:name', (request, response) ->
  name = request.params.name
  title = "Serenade.js example: #{name}"
  source = "/src/#{name}"
  response.render('show.serenade', model: { name, title, source }, layout: false)

app.get '/src/serenade.js', (request, response) ->
  require('./build.coffee').Build.minified (code) ->
    response.send(code)

app.get '/src/:name.coffee', (request, response) ->
  source = fs.readFileSync("./examples/#{request.params.name}.coffee")
  coffee = CoffeeScript.compile(source.toString())
  response.send(coffee)

app.get '/src/:name.js', (request, response) ->
  source = fs.readFileSync("./examples/#{request.params.name}.js")
  response.send(source)

port = process.env.PORT || 3000

app.listen port, -> console.log("Listening on " + port)
