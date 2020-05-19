# frozen_string_literal: true

require File.expand_path(File.join(%w[config initialize]), __dir__)
require_glob('{admin,api}/**/*.rb')

require 'sinatra/base'
require 'sinatra/config_file'

app = Sinatra.new do
  set(:root, ROOT)

  register Sinatra::ConfigFile
  config_file File.join(ROOT, 'config', 'sinatra.yml')

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    Dir.glob("#{ROOT}/{admin,api}/**/*.rb") do |file|
      also_reload file
    end
  end
end

map('/admin') { run SmartAC::Admin::Controller.new(app) }
map('/api') { run SmartAC::Api::Controller.new(app) }
map('/') { run Sinatra.new(app) { get('/') { redirect '/index.html' } } }
