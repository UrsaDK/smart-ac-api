# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:notifications) do
      primary_key :id
      DateTime :created, null: false
      DateTime :updated, null: false
      String :status, default: 'new', null: false, index: true
    end
  end
end
