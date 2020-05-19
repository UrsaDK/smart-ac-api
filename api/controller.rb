# frozen_string_literal: true

require 'json'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/namespace'

require_relative './helpers.rb'

module SmartAC
  module Api
    class Controller < Sinatra::Application
      register Sinatra::Namespace
      helpers SmartAC::Api::Helpers

      # Avoid serving duplicate content
      before '/*/' do
        redirect request.path_info.chomp('/')
      end

      get '/' do
        json(
          title: 'SmartAC API Prototype',
          environment: ENVIRONMENT
        )
      end

      namespace '/user' do
        post '/' do
        end

        get '/' do
        end

        delete '/' do
          halt 405, 'Method Not Allowed' if params['ids'].empty?
        end

        # --

        post '/:id' do
        end

        get '/:id' do
        end

        delete '/:id' do
        end
      end

      namespace '/device' do
        get '/' do
        end

        delete '/' do
          halt 405, 'Method Not Allowed' if params['ids'].empty?
        end

        # --

        get '/:serial_number' do
        end

        put '/:serial_number' do
        end

        delete '/:serial_number' do
        end

        # --

        post '/:serial_number/data' do
          halt 405, 'Method Not Allowed' if params['message'].nil?
          payload = JSON.parse(params['message'], symbolize_names: true)

          if Model::Devices[serial_number: params['serial_number']]
            Model::Devices.register_new_device(payload)
          end

          payload[:data].each do |data|
            Model::Data.new(data).save
            Model::Notifications.new if raise_notification?(data)
          end
        end

        get '/:serial_number/data' do
        end

        # --

        get '/:serial_number/notification' do
        end
      end

      namespace '/data' do
        post '/:id/notification' do
        end

        get '/:id/notification' do
        end
      end

      namespace '/notification' do
        get '/' do
        end
      end
    end
  end
end
