require 'date'

module SmartAC
  module Api
    module Helpers
      def raise_notification?(data)
        return true if data[:carbon_monoxide] > 9
        %w[needs_service needs_new_filter gas_leak].include?(data[:health_status])
      end
    end
  end
end
