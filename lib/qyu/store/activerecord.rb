require_relative "./activerecord/version"
require 'active_record'

module Qyu
  module Store
    module ActiveRecord
      autoload :Adapter,                'qyu/store/activerecord/adapter'
      autoload :ConfigurationValidator, 'qyu/store/activerecord/configuration_validator'
      autoload :Logger,                 'qyu/store/activerecord/logger'
      autoload :Utils,                  'qyu/store/activerecord/utils'
      autoload :Job,                    'qyu/store/activerecord/models/job'
      autoload :Task,                   'qyu/store/activerecord/models/task'
      autoload :Workflow,               'qyu/store/activerecord/models/workflow'

      class << self
        def interface
          defined?(Qyu::Store::Base) ? Qyu::Store::Base : Object
        end
      end
    end
  end

  class << self
    unless defined?(logger)
      def logger=(logger)
        @@__logger = logger
      end

      def logger
        @@__logger ||= Qyu::Store::ActiveRecord::Logger.new(STDOUT)
      end
    end
  end
end

Qyu::Config::StoreConfig.register(Qyu::Store::ActiveRecord::Adapter) if defined?(Qyu::Config::StoreConfig)
Qyu::Factory::StoreFactory.register(Qyu::Store::ActiveRecord::Adapter) if defined?(Qyu::Factory::StoreFactory)
