require 'sinatra'
require 'slim'

enable :inline_templates

get '/' do

end

get '/src/monkey.js' do
  File.read('./extras/monkey.js')
end

get '/src/:name.js' do |name|
  File.read("./examples/#{name}.js")
end

get '/:name' do |name|
  @name = name
  slim :thingy
end

__END__

@@ thingy
doctype html
html
  head
    script[src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"]
    script[src="src/monkey.js"]
    script[src="src/#{@name}.js"]
  body
