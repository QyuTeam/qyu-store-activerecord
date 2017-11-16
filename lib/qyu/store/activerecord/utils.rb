require 'rake'

load 'qyu/store/activerecord/tasks/db.rake'

module Qyu
  module Store
    module ActiveRecord
      class Utils
        def self.ensure_db_ready(db_config)
          begin
            ::ActiveRecord::Base.establish_connection(db_config).connection
          rescue ::ActiveRecord::NoDatabaseError
            # :nocov:
            Rake::Task['qyu:db:create'].invoke
            # :nocov:
          end

          begin
            Rake::Task['qyu:db:migrate_without_schema_update'].invoke
            # :nocov:
          rescue ::ActiveRecord::ConcurrentMigrationError
            ArcYu.logger.info 'Concurrent Qyu database migration running. Skipping...'
            # :nocov:
          end
        end
      end
    end
  end
end
