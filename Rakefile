# frozen_string_literal: true

require File.expand_path(File.join(%w[config initialize]), __dir__)
require_glob('tasks/**/*.rb')

task :default do
  system('rake -sT')
end

namespace :db do
  desc 'Create a new database'
  task create: 'db:migrate'

  desc 'Delete current database (All data will be lost!)'
  task :drop! do
    db = File.expand_path(environment_config('config/sequel.yml')[:database], ROOT)
    puts "Deleting database: #{db}"
    File.delete(db)
  end

  desc "Shortcut for #{Rake.application.current_scope.path}:migrate:all"
  task migrate: 'migrate:all'

  namespace :migrate do
    desc 'Run all migrations in order'
    task :all do
      puts 'Applying all database migrations ...'
      SmartAC::Tasks::Migrate.all
    end

    desc 'Migrate to a specific version'
    task :to, [:migration_number] do |_t, args|
      puts "Transforming database to migration number #{migration_number} ..."
      SmartAC::Tasks::Migrate.to(args.migration_number)
    end
  end
end
