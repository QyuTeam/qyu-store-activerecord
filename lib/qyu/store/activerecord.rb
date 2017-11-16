require_relative "./activerecord/version"

module Qyu
  module Store
    module ActiveRecord
      autoload :Adapter,                'qyu/store/activerecord/adapter'
      autoload :ConfigurationValidator, 'qyu/store/activerecord/configuration_validator'
      autoload :Logger,                 'qyu/store/activerecord/logger'

      class << self
        def interface
          defined?(ArcYu::StateStore::Base) ? ArcYu::StateStore::Base : Object
        end
      end
    end
  end
end
