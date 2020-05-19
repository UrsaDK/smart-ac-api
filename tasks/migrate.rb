# frozen_string_literal: true

require 'sequel/core'

module SmartAC
  module Tasks
    module Migrate
      class << self
        Sequel.extension :migration

        def all
          Sequel::Migrator.run(DB, migrations_dir)
        end

        def to(migration_number)
          Sequel::Migrator.run(DB, migrations_dir, target: migration_number)
        end

        private

        def migrations_dir
          @migrations_dir ||= File.join(ROOT, 'db', 'migrations')
        end
      end
    end
  end
end
