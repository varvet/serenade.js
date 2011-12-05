require 'sinatra'
require 'slim'
require 'coffee-script'

enable :inline_templates

get '/' do
  @examples = Dir.glob('examples/*.{js,coffee}').map { |e| e.split('/').last }
  slim :index
end

get '/src/monkey.js' do
  # ghetto live reload
  if ENV['AUTORELOAD']
    `cake build; cake build:parser; cake build:browser`
  end
  File.read("./extras/monkey.js")
end

get '/src/:name.coffee' do |name|
  CoffeeScript.compile(File.read("./examples/#{name}.coffee"))
end

get '/src/:name.js' do |name|
  File.read("./examples/#{name}.js")
end

get '/:name' do |name|
  @name = name
  slim :show
end

__END__

@@ index
doctype html
html
  head
  body
    - @examples.each do |example|
      p
        a[href="/#{example}"] = example

@@ show
doctype html
html
  head
    script[src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"]
    script[src="src/monkey.js"]
    script[src="src/#{@name}"]
  body
