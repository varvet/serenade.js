require 'sinatra/base'
require File.expand_path('examples/app', File.dirname(__FILE__))

run Sinatra::Application
