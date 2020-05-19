# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:devices) do
      primary_key :id
      DateTime :created, null: false
      DateTime :updated, null: false
      String :serial_number, null: false, unique: true, index: true
      String :firmware_version, null: false
      String :status, default: 'enabled', null: false, index: true
    end
  end
end
