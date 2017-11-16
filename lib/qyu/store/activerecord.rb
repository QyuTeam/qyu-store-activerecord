require_relative "./activerecord/version"
require 'active_record'

module Qyu
  module Store
    module ActiveRecord
      autoload :Adapter,                'qyu/store/activerecord/adapter'
      autoload :ConfigurationValidator, 'qyu/store/activerecord/configuration_validator'
      autoload :Logger,                 'qyu/store/activerecord/logger'
      autoload :Job,                    'qyu/store/activerecord/models/job'
      autoload :Task,                   'qyu/store/activerecord/models/task'
      autoload :Workflow,               'qyu/store/activerecord/models/workflow'

      class << self
        def interface
          defined?(ArcYu::StateStore::Base) ? ArcYu::StateStore::Base : Object
        end
      end
    end
  end
end
