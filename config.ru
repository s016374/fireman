require File.expand_path('apps/app', File.dirname(__FILE__))

use Rack::Reloader

run App
