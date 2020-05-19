# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      DateTime :created, null: false
      DateTime :updated, null: false
      String :full_name, null: false
      String :username, null: false, index: true
      String :password, null: false
      String :status, default: 'enabled', null: false, index: true
    end
  end
end
