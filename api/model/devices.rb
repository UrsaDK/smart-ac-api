# frozen_string_literal: true

require_relative './data'

module SmartAC
  module Api
    module Model
      class Devices < Sequel::Model
        Sequel::Model.plugin :timestamps,
                             create: :created,
                             update: :updated,
                             update_on_create: true

        one_to_many :data

        class << self
          def register_new_device(payload)
            new(
              serial_number: payload[:serial_number],
              firmware_version: payload[:firmware_version]
            ).save
          end
        end
      end
    end
  end
end
