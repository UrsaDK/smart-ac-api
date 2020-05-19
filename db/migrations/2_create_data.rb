# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:data) do
      primary_key :id
      DateTime :created, null: false
      DateTime :updated, null: false
      Float :temperature, null: true
      Float :humidity, null: true
      Integer :carbon_monoxide, null: true
      String :health_status, null: true, size: 150
    end
  end
end
