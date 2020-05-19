# frozen_string_literal: true

require 'sinatra/base'

module SmartAC
  module Admin
    class Controller < Sinatra::Application
      get '/' do
        redirect '/admin.html'
      end
    end
  end
end
