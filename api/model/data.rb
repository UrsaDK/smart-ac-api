# frozen_string_literal: true

require_relative './devices'
require_relative './notifications'

module SmartAC
  module Api
    module Model
      class Data < Sequel::Model(:data)
        Sequel::Model.plugin :timestamps,
                             create: :created,
                             update: :updated,
                             update_on_create: true

        many_to_one :devices
        one_to_many :notifications
      end
    end
  end
end
