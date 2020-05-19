# frozen_string_literal: true

require_relative './notifications'

module SmartAC
  module Api
    module Model
      class Users < Sequel::Model
        Sequel::Model.plugin :timestamps,
                             create: :created,
                             update: :updated,
                             update_on_create: true

        one_to_many :notifications
      end
    end
  end
end
