# frozen_string_literal: true

ROOT = File.expand_path('..', __dir__).freeze
ENVIRONMENT = (ENV['ENVIRONMENT'] || 'development').tap do |env|
  case File.basename($PROGRAM_NAME)
  when 'rake'
    ENV['RAKE_ENV'] = env.freeze
  when 'rackup'
    ENV['RACK_ENV'] = env.freeze
  end
end.freeze

# Auto-require environment specific gems
require 'bundler/setup'
Bundler.require(ENVIRONMENT.to_sym)

# Prepend ROOT relative directory to LOAD_PATH, if it isn't already in it.
# Usage:  load_path('lib/project1', 'lib/project2')
#         load_path(%w[lib project1], %w[lib project2])
def load_path(*paths)
  paths.each do |path|
    dir = File.expand_path(File.join(path), ROOT)
    $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
  end
end

# Require ROOT relative files matching the glob pattern. If a block is given,
# then each file is yielded to it and is required if the block returns true.
# Usage:  require_glob('lib/**/*.rb', 'tasks/**/*.rb')
#         require_glob(%w[lib ** *.rb], %w[tasks ** *.rb])
def require_glob(*patterns)
  patterns = ['**/*.rb'] if patterns.empty?
  Dir.glob(patterns.map { |p| File.join(p) }, base: ROOT) do |file|
    require File.expand_path(file, ROOT) if !block_given? || yield(file)
  end
end

# Parse ROOT relative config files (YAML) into hashes with symbolised keys.
# Hashes from multiple files are merged. Files are pre-processed with ERB.
# Config values can be manipulated by adding an option block to the method.
# Usage:  environment_config('config/file1.yml', config/file2.yml)
#         environment_config(%w[config file1.yml], %w[config file2.yml]) do |c|
#           c.key = decrypt(c.key)
#         end
%w[erb yaml].each { |gem| require gem }
def environment_config(*paths)
  config = paths.each_with_object({}) do |path, result|
    file = File.expand_path(File.join(path), ROOT)
    text = ERB.new(File.read(file)).result(binding)
    data = YAML.safe_load(text, [], [], true, file, symbolize_names: true)
    result.merge!(data[ENVIRONMENT.to_sym])
  end
  config.tap { |c| yield(c) if block_given? }.freeze
end

# Establish database connection before model definition
%w[sequel sqlite3].each { |gem| require gem }
DB = Sequel.connect(environment_config('config/sequel.yml'))
