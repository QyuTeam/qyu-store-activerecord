module Qyu
  module Store
    module ActiveRecord
      class ConfigurationValidator
        REQUIRED_ATTRIBUTES = %i(db_type db_name db_host db_port).freeze

        attr_reader :errors

        def initialize(config)
          @config = config
          @errors = []
        end

        def valid?
          validate
          errors.empty?
        end

        def validate
          REQUIRED_ATTRIBUTES.each do |attribute|
            next if @config[attribute].present?

            @errors << "#{attribute} must be present."
          end

          validate_database_adapter
        end

        private

        def validate_database_adapter
          sample_config = { 'test' => { adapter: @config[:db_type] } }

          ::ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(sample_config).spec(:test)
        rescue LoadError => ex
          @errors << ex.message
        end
      end
    end
  end
end
