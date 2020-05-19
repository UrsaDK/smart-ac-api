# frozen_string_literal: true

require_relative './data'
require_relative './users'

module SmartAC
  module Api
    module Model
      class Notifications < Sequel::Model
        Sequel::Model.plugin :timestamps,
                             create: :created,
                             update: :updated,
                             update_on_create: true

        many_to_one :users
        many_to_one :data
      end
    end
  end
end
