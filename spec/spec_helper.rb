# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'

SimpleCov.start

require "qyu/store/activerecord"

require 'pry'
require 'shoulda-matchers'
require 'factory_bot'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FactoryBot::Syntax::Methods
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.before(:each) do
    # ignore_puts
    reset_config
    # begin
    #   ArcYu.config = ArcYu::Config.new({ type: :in_memory }, state_store_config)
    # rescue NameError
    #   ArcYu.config = ArcYu::Config.new({ type: :in_memory }, { type: :in_memory, lease_period: 60 })
    # end
    purge_db
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
  end
end

logger = Logger.new(STDOUT)
logger.level = Logger::FATAL

Qyu.logger = logger

def reset_config
  Qyu::Store::ActiveRecord::Adapter.new(active_record_config)
end

def ignore_puts
  allow($stdout).to receive(:write)
end

def active_record_config
  {
    type: :active_record,
    db_type: ENV.fetch('DB_ADAPTER', 'postgresql'),
    db_host: ENV.fetch('DB_HOST', '0.0.0.0'),
    db_port: ENV.fetch('DB_PORT', 5432),
    db_name: ENV.fetch('DB_NAME', 'arc_yu_test'),
    db_user: ENV.fetch('DB_USERNAME', ENV['POSTGRESQL_DEV_USERNAME']),
    db_password: ENV.fetch('DB_PASSWORD', ENV['POSTGRESQL_DEV_PASSWORD']),
    lease_period: 60
  }
end

def purge_db
  Qyu::Store::ActiveRecord::Task.where.not(parent_task_id: nil).order(parent_task_id: :desc).each(&:delete)
  Qyu::Store::ActiveRecord::Task.delete_all
  Qyu::Store::ActiveRecord::Job.delete_all
  Qyu::Store::ActiveRecord::Workflow.delete_all
end
